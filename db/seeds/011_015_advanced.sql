-- ver0.3: 고급 5종 (B2-C1 Level)
-- Lessons 11-15

-- Lesson 11: 비즈니스
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence) VALUES
  ('00000000-0000-0000-0000-000000000011', 'les_business_011', '비즈니스 회의', 'Business Meeting', 'B2', 'en', 'ko', '비즈니스 상황에서 사용하는 격식있는 표현을 배웁니다.', 'Learn formal business expressions.', 11);

INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, sequence) VALUES
  ('00000000-0000-0000-0011-000000000001', '00000000-0000-0000-0000-000000000011', 'stg_meeting', '회의', 'Meeting', 'office', 1),
  ('00000000-0000-0000-0011-000000000002', '00000000-0000-0000-0000-000000000011', 'stg_presentation', '발표', 'Presentation', 'office', 2);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence) VALUES
  ('00000000-0000-0011-0001-000000000001', '00000000-0000-0000-0011-000000000001', 'act_agree', 'dialogue', '동의한다고 격식있게 말하세요.', 'Say you agree formally', '{"primary": "동의합니다"}'::jsonb, 3, 1),
  ('00000000-0000-0011-0001-000000000002', '00000000-0000-0000-0011-000000000001', 'act_opinion', 'dialogue', '의견을 말하겠다고 하세요.', 'Say you will give opinion', '{"primary": "제 의견을 말씀드리겠습니다"}'::jsonb, 3, 2),
  ('00000000-0000-0011-0002-000000000001', '00000000-0000-0000-0011-000000000002', 'act_present', 'dialogue', '발표를 시작하겠다고 하세요.', 'Say you will start presentation', '{"primary": "발표를 시작하겠습니다"}'::jsonb, 3, 1);

-- Lesson 12: 뉴스와 시사
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence) VALUES
  ('00000000-0000-0000-0000-000000000012', 'les_news_012', '뉴스 이해하기', 'Understanding News', 'B2', 'en', 'ko', '뉴스와 시사 용어를 이해하고 의견을 표현합니다.', 'Learn news vocabulary.', 12);

INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, sequence) VALUES
  ('00000000-0000-0000-0012-000000000001', '00000000-0000-0000-0000-000000000012', 'stg_politics', '정치', 'Politics', 'cafe', 1),
  ('00000000-0000-0000-0012-000000000002', '00000000-0000-0000-0000-000000000012', 'stg_economy', '경제', 'Economy', 'cafe', 2);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence) VALUES
  ('00000000-0000-0012-0001-000000000001', '00000000-0000-0000-0012-000000000001', 'act_election', 'dialogue', '선거에 대해 이야기하세요.', 'Talk about election', '{"primary": "선거가 곧 있어요"}'::jsonb, 3, 1),
  ('00000000-0000-0012-0002-000000000001', '00000000-0000-0000-0012-000000000002', 'act_inflation', 'dialogue', '물가가 올랐다고 말하세요.', 'Say prices went up', '{"primary": "물가가 올랐어요"}'::jsonb, 3, 1);

-- Lesson 13: 한국 문화
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence) VALUES
  ('00000000-0000-0000-0000-000000000013', 'les_culture_013', '한국 문화', 'Korean Culture', 'C1', 'en', 'ko', '한국의 전통과 현대 문화를 이야기합니다.', 'Learn about Korean culture.', 13);

INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, sequence) VALUES
  ('00000000-0000-0000-0013-000000000001', '00000000-0000-0000-0000-000000000013', 'stg_tradition', '전통', 'Tradition', 'museum', 1),
  ('00000000-0000-0000-0013-000000000002', '00000000-0000-0000-0000-000000000013', 'stg_modern', '현대 문화', 'Modern Culture', 'street', 2);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence) VALUES
  ('00000000-0000-0013-0001-000000000001', '00000000-0000-0000-0013-000000000001', 'act_hanbok', 'dialogue', '한복에 대해 설명하세요.', 'Explain about Hanbok', '{"primary": "한복은 전통 의상입니다"}'::jsonb, 4, 1),
  ('00000000-0000-0013-0001-000000000002', '00000000-0000-0000-0013-000000000001', 'act_respect', 'dialogue', '존중의 문화를 설명하세요.', 'Explain respect culture', '{"primary": "한국은 존중의 문화가 있어요"}'::jsonb, 4, 2),
  ('00000000-0000-0013-0002-000000000001', '00000000-0000-0000-0013-000000000002', 'act_kpop', 'dialogue', 'K-pop에 대해 이야기하세요.', 'Talk about K-pop', '{"primary": "K-pop이 인기가 많아요"}'::jsonb, 3, 1);

-- Lesson 14: 고급 문법
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence) VALUES
  ('00000000-0000-0000-0000-000000000014', 'les_advanced_014', '고급 표현', 'Advanced Expressions', 'C1', 'en', 'ko', '고급 문법과 관용 표현을 배웁니다.', 'Learn advanced grammar.', 14);

INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, sequence) VALUES
  ('00000000-0000-0000-0014-000000000001', '00000000-0000-0000-0000-000000000014', 'stg_idioms', '관용구', 'Idioms', 'cafe', 1),
  ('00000000-0000-0000-0014-000000000002', '00000000-0000-0000-0000-000000000014', 'stg_honorifics', '높임말', 'Honorifics', 'office', 2);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence) VALUES
  ('00000000-0000-0014-0001-000000000001', '00000000-0000-0000-0014-000000000001', 'act_idiom1', 'dialogue', '금상첨화라는 표현을 사용하세요.', 'Use the idiom 금상첨화', '{"primary": "금상첨화네요"}'::jsonb, 4, 1),
  ('00000000-0000-0014-0002-000000000001', '00000000-0000-0000-0014-000000000002', 'act_honorific', 'dialogue', '높임말로 계시다를 사용하세요.', 'Use 계시다 honorific', '{"primary": "사장님께서 계십니다"}'::jsonb, 4, 1);

-- Lesson 15: 토론과 논쟁
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence) VALUES
  ('00000000-0000-0000-0000-000000000015', 'les_debate_015', '토론하기', 'Debate', 'C1', 'en', 'ko', '논리적으로 의견을 주장하고 반박하는 방법을 배웁니다.', 'Learn debate skills.', 15);

INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, sequence) VALUES
  ('00000000-0000-0000-0015-000000000001', '00000000-0000-0000-0000-000000000015', 'stg_argue', '주장하기', 'Arguing', 'office', 1),
  ('00000000-0000-0000-0015-000000000002', '00000000-0000-0000-0000-000000000015', 'stg_counter', '반박하기', 'Countering', 'office', 2);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence) VALUES
  ('00000000-0000-0015-0001-000000000001', '00000000-0000-0000-0015-000000000001', 'act_claim', 'dialogue', '주장을 펼치세요.', 'Make a claim', '{"primary": "제 주장은 이렇습니다"}'::jsonb, 4, 1),
  ('00000000-0000-0015-0001-000000000002', '00000000-0000-0000-0015-000000000001', 'act_evidence', 'dialogue', '근거를 제시하세요.', 'Present evidence', '{"primary": "근거는 다음과 같습니다"}'::jsonb, 4, 2),
  ('00000000-0000-0015-0002-000000000001', '00000000-0000-0000-0015-000000000002', 'act_disagree', 'dialogue', '반대 의견을 말하세요.', 'Express disagreement', '{"primary": "반대 의견이 있습니다"}'::jsonb, 4, 1);

DO $$
DECLARE
  total_lessons INT;
  total_activities INT;
BEGIN
  SELECT COUNT(*) INTO total_lessons FROM lessons;
  SELECT COUNT(*) INTO total_activities FROM activities;
  
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'ver0.3 완료! (중급 5종 + 고급 5종)';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '총 Lessons: %', total_lessons;
  RAISE NOTICE '총 Activities: %', total_activities;
  RAISE NOTICE '==============================================';
  RAISE NOTICE '초급 (A1): 5 lessons';
  RAISE NOTICE '중급 (A2-B1): 5 lessons';
  RAISE NOTICE '고급 (B2-C1): 5 lessons';
  RAISE NOTICE '==============================================';
END $$;
