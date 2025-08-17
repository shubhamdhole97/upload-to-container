
// Simple file upload server for Docker
const express = require('express');
const multer  = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;
const UPLOAD_DIR = path.join(__dirname, 'uploads');

// Ensure upload dir exists
fs.mkdirSync(UPLOAD_DIR, { recursive: true });

// Multer disk storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, UPLOAD_DIR);
  },
  filename: function (req, file, cb) {
    const safe = file.originalname.replace(/[^a-zA-Z0-9.\-_]/g, '_');
    cb(null, Date.now() + '-' + safe);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: parseInt(process.env.MAX_FILE_SIZE || (50 * 1024 * 1024)) } // default 50MB
});

app.use(express.static(path.join(__dirname, 'public')));

// Health check
app.get('/healthz', (req, res) => res.json({ ok: true }));

// List uploaded files
app.get('/files', async (req, res) => {
  try {
    const files = await fs.promises.readdir(UPLOAD_DIR);
    const detailed = await Promise.all(files.map(async (f) => {
      const stat = await fs.promises.stat(path.join(UPLOAD_DIR, f));
      return { name: f, size: stat.size, mtime: stat.mtime };
    }));
    detailed.sort((a,b) => b.mtime - a.mtime);
    res.json(detailed);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to list files' });
  }
});

// Download endpoint
app.get('/download/:name', (req, res) => {
  const filePath = path.join(UPLOAD_DIR, req.params.name);
  if (!filePath.startsWith(UPLOAD_DIR)) return res.status(400).send('Invalid path');
  if (!fs.existsSync(filePath)) return res.status(404).send('Not found');
  return res.download(filePath);
});

// Upload endpoint (multiple files allowed)
app.post('/upload', upload.array('files', 20), (req, res) => {
  res.json({
    uploaded: (req.files || []).map(f => ({ filename: f.filename, size: f.size }))
  });
});

// Serve uploaded files for preview (images, etc.)
app.use('/uploads', express.static(UPLOAD_DIR));

app.listen(PORT, () => {
  console.log(`File upload server running on http://0.0.0.0:${PORT}`);
});
