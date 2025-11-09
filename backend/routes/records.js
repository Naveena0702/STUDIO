const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { getDB } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
router.use(authenticateToken);

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadsDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, `${req.user.id}-${uniqueSuffix}${path.extname(file.originalname)}`);
    }
});

const upload = multer({
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024 // 10MB limit
    },
    fileFilter: (req, file, cb) => {
        const allowedTypes = /jpeg|jpg|png|pdf|doc|docx/;
        const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
        const mimetype = allowedTypes.test(file.mimetype);

        if (mimetype && extname) {
            return cb(null, true);
        } else {
            cb(new Error('Invalid file type. Only images, PDFs, and documents are allowed.'));
        }
    }
});

// Upload medical record
router.post('/', upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ error: 'No file uploaded' });
    }

    const { record_type, tags } = req.body;
    const db = getDB();

    db.run(
        `INSERT INTO medical_records 
     (user_id, file_name, file_path, file_type, record_type, tags)
     VALUES (?, ?, ?, ?, ?, ?)`,
        [
            req.user.id,
            req.file.originalname,
            req.file.filename,
            req.file.mimetype,
            record_type || 'general',
            tags || null
        ],
        function (err) {
            if (err) {
                // Delete uploaded file if database insert fails
                fs.unlinkSync(req.file.path);
                return res.status(500).json({ error: 'Failed to save record' });
            }

            res.status(201).json({
                message: 'Medical record uploaded successfully',
                record: {
                    id: this.lastID,
                    file_name: req.file.originalname,
                    file_type: req.file.mimetype,
                    record_type: record_type || 'general',
                    created_at: new Date().toISOString()
                }
            });
        }
    );
});

// Get all medical records
router.get('/', (req, res) => {
    const db = getDB();

    db.all(
        `SELECT id, file_name, file_type, record_type, tags, created_at
     FROM medical_records 
     WHERE user_id = ? 
     ORDER BY created_at DESC`,
        [req.user.id],
        (err, records) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            res.json({ records: records || [] });
        }
    );
});

// Get specific record
router.get('/:id', (req, res) => {
    const db = getDB();

    db.get(
        `SELECT * FROM medical_records 
     WHERE id = ? AND user_id = ?`,
        [req.params.id, req.user.id],
        (err, record) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (!record) {
                return res.status(404).json({ error: 'Record not found' });
            }

            res.json({ record });
        }
    );
});

// Download file
router.get('/:id/download', (req, res) => {
    const db = getDB();

    db.get(
        `SELECT file_path, file_name, file_type 
     FROM medical_records 
     WHERE id = ? AND user_id = ?`,
        [req.params.id, req.user.id],
        (err, record) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (!record) {
                return res.status(404).json({ error: 'Record not found' });
            }

            const filePath = path.join(uploadsDir, record.file_path);

            if (!fs.existsSync(filePath)) {
                return res.status(404).json({ error: 'File not found on server' });
            }

            res.download(filePath, record.file_name, (err) => {
                if (err) {
                    console.error('Download error:', err);
                }
            });
        }
    );
});

// Delete record
router.delete('/:id', (req, res) => {
    const db = getDB();

    // Get file info before deleting
    db.get(
        `SELECT file_path FROM medical_records 
     WHERE id = ? AND user_id = ?`,
        [req.params.id, req.user.id],
        (err, record) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (!record) {
                return res.status(404).json({ error: 'Record not found' });
            }

            // Delete from database
            db.run(
                `DELETE FROM medical_records 
         WHERE id = ? AND user_id = ?`,
                [req.params.id, req.user.id],
                function (err) {
                    if (err) {
                        return res.status(500).json({ error: 'Failed to delete record' });
                    }

                    // Delete file from filesystem
                    const filePath = path.join(uploadsDir, record.file_path);
                    if (fs.existsSync(filePath)) {
                        fs.unlinkSync(filePath);
                    }

                    res.json({ message: 'Record deleted successfully' });
                }
            );
        }
    );
});

module.exports = router;

