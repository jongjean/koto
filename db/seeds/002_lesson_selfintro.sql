-- Lesson 2: 자기소개 (Self-Introduction)
-- For Korean Together ver0.2

-- =============================================================================
-- Lesson 2: 자기소개 (Self-Introduction)
-- =============================================================================
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence)
VALUES (
  '00000000-0000-0000-0000-000000000002',
  'les_selfintro_002',
  '자기소개',
  'Self-Introduction',
  'A1',
  'en',
  'ko',
  '자신을 소개하는 다양한 표현을 배웁니다. 이름, 국적, 직업, 취미를 말하는 방법을 익힙니다.',
  'Learn how to introduce yourself. Practice expressing your name, nationality, occupation, and hobbies.',
  2
);

-- =============================================================================
-- Stage 1: 이름 소개 (Introducing Name)
-- =============================================================================
INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, objective_ko, objective_en, sequence)
VALUES (
  '00000000-0000-0000-0002-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'stg_name_intro',
  '이름 소개하기',
  'Introducing Your Name',
  'street',
  '이름을 소개하는 다양한 표현을 배웁니다.',
  'Learn various ways to introduce your name.',
  1
);

-- Activities for Stage 1: Name
INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence)
VALUES
  ('00000000-0000-0002-0001-000000000001', '00000000-0000-0000-0002-000000000001', 'act_my_name_is', 'dialogue',
   '이름을 소개해보세요.',
   'Introduce your name.',
   '{"primary": "제 이름은 ~입니다", "variations": ["저는 ~입니다", "이름은 ~예요"], "formality": "formal", "context": "정중하게 이름을 소개할 때 사용합니다."}'::jsonb, 1, 1),
   
  ('00000000-0000-0002-0001-000000000002', '00000000-0000-0000-0002-000000000001', 'act_call_me', 'dialogue',
   '편하게 부를 이름을 알려주세요.',
   'Tell them what to call you casually.',
   '{"primary": "~라고 불러주세요", "variations": ["~라고 해주세요", "저를 ~라고 해요"], "formality": "casual", "context": "친근하게 부를 이름을 알려줄 때 사용합니다."}'::jsonb, 2, 2);

-- =============================================================================
-- Stage 2: 국적과 직업 (Nationality and Occupation)
-- =============================================================================
INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, objective_ko, objective_en, sequence)
VALUES (
  '00000000-0000-0000-0002-000000000002',
  '00000000-0000-0000-0000-000000000002',
  'stg_nationality_job',
  '국적과 직업 말하기',
  'Stating Nationality and Occupation',
  'office',
  '국적과 직업을 말하는 방법을 배웁니다.',
  'Learn how to state your nationality and occupation.',
  2
);

-- Activities for Stage 2: Nationality and Job
INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence)
VALUES
  ('00000000-0000-0002-0002-000000000001', '00000000-0000-0000-0002-000000000002', 'act_from_country', 'dialogue',
   '어느 나라에서 왔는지 말해보세요.',
   'Say which country you are from.',
   '{"primary": "저는 ~에서 왔어요", "variations": ["~에서 왔습니다", "~사람이에요"], "formality": "neutral", "context": "국적을 말할 때 사용합니다."}'::jsonb, 1, 1),
   
  ('00000000-0000-0002-0002-000000000002', '00000000-0000-0000-0002-000000000002', 'act_occupation', 'dialogue',
   '직업을 말해보세요.',
   'State your occupation.',
   '{"primary": "저는 ~입니다", "variations": ["~로 일해요", "직업은 ~예요"], "formality": "formal", "context": "직업을 소개할 때 사용합니다. (예: 학생, 선생님, 회사원)"}'::jsonb, 2, 2),
   
  ('00000000-0000-0002-0002-000000000003', '00000000-0000-0000-0002-000000000002', 'act_work_at', 'dialogue',
   '어디에서 일하는지 말해보세요.',
   'Say where you work.',
   '{"primary": "~에서 일해요", "variations": ["~에 다녀요", "~에서 근무해요"], "formality": "neutral", "context": "직장을 말할 때 사용합니다."}'::jsonb, 2, 3);

-- =============================================================================
-- Stage 3: 취미와 관심사 (Hobbies and Interests)
-- =============================================================================
INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, objective_ko, objective_en, sequence)
VALUES (
  '00000000-0000-0000-0002-000000000003',
  '00000000-0000-0000-0000-000000000002',
  'stg_hobbies',
  '취미 말하기',
  'Talking About Hobbies',
  'cafe',
  '취미와 좋아하는 것을 말하는 방법을 배웁니다.',
  'Learn how to talk about hobbies and things you like.',
  3
);

-- Activities for Stage 3: Hobbies
INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence)
VALUES
  ('00000000-0000-0002-0003-000000000001', '00000000-0000-0000-0002-000000000003', 'act_like_something', 'dialogue',
   '좋아하는 것을 말해보세요.',
   'Say what you like.',
   '{"primary": "저는 ~를 좋아해요", "variations": ["~을 좋아합니다", "~를 좋아하는 편이에요"], "formality": "neutral", "context": "좋아하는 것을 표현할 때 사용합니다."}'::jsonb, 1, 1),
   
  ('00000000-0000-0002-0003-000000000002', '00000000-0000-0000-0002-000000000003', 'act_hobby', 'dialogue',
   '취미가 무엇인지 말해보세요.',
   'Say what your hobby is.',
   '{"primary": "제 취미는 ~예요", "variations": ["취미는 ~입니다", "~하는 걸 좋아해요"], "formality": "neutral", "context": "취미를 소개할 때 사용합니다."}'::jsonb, 2, 2),
   
  ('00000000-0000-0002-0003-000000000003', '00000000-0000-0000-0002-000000000003', 'act_good_at', 'dialogue',
   '잘하는 것을 말해보세요.',
   'Say what you are good at.',
   '{"primary": "~를 잘해요", "variations": ["~을 잘합니다", "~에 자신 있어요"], "formality": "neutral", "context": "자신의 강점을 말할 때 사용합니다."}'::jsonb, 2, 3);

-- =============================================================================
-- Verification
-- =============================================================================
DO $$
DECLARE
  lesson_count INT;
  stage_count INT;
  activity_count INT;
BEGIN
  SELECT COUNT(*) INTO lesson_count FROM lessons WHERE code = 'les_selfintro_002';
  SELECT COUNT(*) INTO stage_count FROM stages WHERE lesson_id = '00000000-0000-0000-0000-000000000002';
  SELECT COUNT(*) INTO activity_count FROM activities WHERE stage_id IN (
    SELECT id FROM stages WHERE lesson_id = '00000000-0000-0000-0000-000000000002'
  );
  
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Lesson 2 데이터 삽입 완료!';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Lessons: %', lesson_count;
  RAISE NOTICE 'Stages: %', stage_count;
  RAISE NOTICE 'Activities: %', activity_count;
  RAISE NOTICE '==============================================';
END $$;
