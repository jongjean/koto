const express = require('express');
const db = require('../utils/database');
const logger = require('../utils/logger');

const router = express.Router();

// POST /api/v1/sessions - 새 세션 시작
router.post('/', async (req, res, next) => {
    try {
        const { user_id, lesson_id, lang_pack = 'ko-en' } = req.body;

        if (!user_id || !lesson_id) {
            return res.status(400).json({
                error: 'user_id and lesson_id are required'
            });
        }

        // 세션 생성
        const result = await db.query(`
      INSERT INTO sessions (user_id, lesson_id, status)
      VALUES ($1, $2, 'active')
      RETURNING *
    `, [user_id, lesson_id]);

        const session = result.rows[0];

        logger.info('Session created', {
            session_id: session.id,
            user_id,
            lesson_id
        });

        res.status(201).json({
            session_id: session.id,
            user_id: session.user_id,
            lesson_id: session.lesson_id,
            status: session.status,
            started_at: session.started_at
        });

    } catch (error) {
        next(error);
    }
});

// GET /api/v1/sessions/:id - 세션 조회
router.get('/:id', async (req, res, next) => {
    try {
        const { id } = req.params;

        const result = await db.query(`
      SELECT 
        s.*,
        l.title_en as lesson_title,
        l.level as lesson_level
      FROM sessions s
      LEFT JOIN lessons l ON s.lesson_id =l.id
      WHERE s.id = $1
    `, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Session not found' });
        }

        res.json(result.rows[0]);

    } catch (error) {
        next(error);
    }
});

// GET /api/v1/sessions - 세션 목록 (사용자별)
router.get('/', async (req, res, next) => {
    try {
        const { user_id } = req.query;

        if (!user_id) {
            return res.status(400).json({ error: 'user_id is required' });
        }

        const result = await db.query(`
      SELECT 
        s.*,
        l.title_en as lesson_title,
        l.level as lesson_level
      FROM sessions s
      LEFT JOIN lessons l ON s.lesson_id = l.id
      WHERE s.user_id = $1
      ORDER BY s.started_at DESC
      LIMIT 50
    `, [user_id]);

        res.json({
            sessions: result.rows,
            count: result.rows.length
        });

    } catch (error) {
        next(error);
    }
});

module.exports = router;
