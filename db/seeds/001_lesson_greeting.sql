-- Lesson Seed Data: Lesson 1 - Greetings (인사하기)
-- For Korean Together ver0.1 testing

-- =============================================================================
-- Lesson 1: 인사하기 (Greetings)
-- =============================================================================
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'les_greeting_001',
  '인사하기',
  'Greetings',
  'A1',
  'en',
  'ko',
  '한국어로 인사하는 방법을 배웁니다. 다양한 상황에서 사용하는 인사말을 익힙니다.',
  'Learn how to greet in Korean. Practice various greeting expressions for different situations.',
  1
);

-- =============================================================================
-- Stage 1: 기본 인사 (Basic Greetings)
-- =============================================================================
INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, objective_ko, objective_en, sequence)
VALUES (
  '00000000-0000-0000-0001-000000000001',
  '00000000-0000-0000-0000-000000000001',
  'stg_basic_greeting',
  '기본 인사',
  'Basic Greetings',
  'street',
  '기본적인 인사말을 배우고 연습합니다.',
  'Learn and practice basic greeting expressions.',
  1
);

-- =============================================================================
-- Activities for Stage 1
-- =============================================================================

-- Activity 1: 안녕하세요
INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence)
VALUES (
  '00000000-0000-0001-0001-000000000001',
  '00000000-0000-0000-0001-000000000001',
  'act_hello',
  'dialogue',
  '처음 만난 사람에게 인사해보세요.',
  'Greet someone you meet for the first time.',
  '{
    "primary": "안녕하세요",
    "variations": ["안녕하십니까", "반갑습니다"],
    "formality": "formal",
    "context": "첫 만남에서 사용하는 기본 인사입니다."
  }'::jsonb,
  1,
  1
);

-- Activity 2: 반갑습니다
INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence)
VALUES (
  '00000000-0000-0001-0001-000000000002',
  '00000000-0000-0000-0001-000000000001',
  'act_nice_to_meet',
  'dialogue',
  '상대방을 만나서 반갑다고 말해보세요.',
  'Say "nice to meet you" in Korean.',
  '{
    "primary": "반갑습니다",
    "variations": ["만나서 반갑습니다", "만나서 반가워요"],
    "formality": "formal",
    "context": "처음 만난 사람에게 반가움을 표현합니다."
  }'::jsonb,
  1,
  2
);

-- Activity 3: 처음 뵙겠습니다
INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence)
VALUES (
  '00000000-0000-0001-0001-000000000003',
  '00000000-0000-0000-0001-000000000001',
  'act_first_time',
  'dialogue',
  '격식을 차려 처음 뵙는다고 말해보세요.',
  'Say "It is my first time meeting you" in a formal way.',
  '{
    "primary": "처음 뵙겠습니다",
    "variations": ["처음 뵙습니다", "처음 만나뵙겠습니다"],
    "formality": "very_formal",
    "context": "비즈니스나 격식있는 자리에서 사용합니다."
  }'::jsonb,
  2,
  3
);

-- Activity 4: 잘 부탁드립니다
INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence)
VALUES (
  '00000000-0000-0001-0001-000000000004',
  '00000000-0000-0000-0001-000000000001',
  'act_please_take_care',
  'dialogue',
  '앞으로 잘 부탁한다고 말해보세요.',
  'Say "Please take care of me" or "I look forward to working with you".',
  '{
    "primary": "잘 부탁드립니다",
    "variations": ["잘 부탁합니다", "잘 부탁드려요"],
    "formality": "formal",
    "context": "처음 만난 후 앞으로의 관계를 부탁할 때 사용합니다."
  }'::jsonb,
  2,
  4
);

-- Activity 5: 안녕히 가세요
INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence)
VALUES (
  '00000000-0000-0001-0001-000000000005',
  '00000000-0000-0000-0001-000000000001',
  'act_goodbye',
  'dialogue',
  '가는 사람에게 작별 인사를 해보세요.',
  'Say goodbye to someone who is leaving.',
  '{
    "primary": "안녕히 가세요",
    "variations": ["안녕히 계세요", "또 만나요"],
    "formality": "formal",
    "context": "헤어질 때 사용하는 인사입니다. 가는 사람에게는 ''가세요'', 남는 사람에게는 ''계세요''를 사용합니다."
  }'::jsonb,
  2,
  5
);

-- =============================================================================
-- Verification
-- =============================================================================
DO $$
DECLARE
  lesson_count INT;
  stage_count INT;
  activity_count INT;
BEGIN
  SELECT COUNT(*) INTO lesson_count FROM lessons WHERE code = 'les_greeting_001';
  SELECT COUNT(*) INTO stage_count FROM stages WHERE code = 'stg_basic_greeting';
  SELECT COUNT(*) INTO activity_count FROM activities WHERE stage_id = '00000000-0000-0000-0001-000000000001';
  
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Lesson Seed Data 삽입 완료!';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Lessons: %', lesson_count;
  RAISE NOTICE 'Stages: %', stage_count;
  RAISE NOTICE 'Activities: %', activity_count;
  RAISE NOTICE '==============================================';
END $$;
