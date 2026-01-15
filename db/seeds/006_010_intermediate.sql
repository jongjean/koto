-- ver0.3: 중급 5종 (A2-B1 Level)
-- Lessons 6-10

-- Lesson 6: 은행/우체국
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence) VALUES
  ('00000000-0000-0000-0000-000000000006', 'les_bank_006', '은행 업무', 'Banking', 'A2', 'en', 'ko', '은행에서 필요한 기본 업무를 처리하는 표현을 배웁니다.', 'Learn essential banking expressions.', 6);

INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, sequence) VALUES
  ('00000000-0000-0000-0006-000000000001', '00000000-0000-0000-0000-000000000006', 'stg_account', '계좌 개설', 'Opening Account', 'bank', 1),
  ('00000000-0000-0000-0006-000000000002', '00000000-0000-0000-0000-000000000006', 'stg_deposit', '입출금', 'Deposit/Withdraw', 'bank', 2),
  ('00000000-0000-0000-0006-000000000003', '00000000-0000-0000-0000-000000000006', 'stg_remit', '송금하기', 'Money Transfer', 'bank', 3);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence) VALUES
  ('00000000-0000-0006-0001-000000000001', '00000000-0000-0000-0006-000000000001', 'act_open_account', 'dialogue', '계좌를 개설하고 싶다고 말하세요.', 'Say you want to open an account', '{"primary": "계좌를 개설하고 싶어요"}'::jsonb, 2, 1),
  ('00000000-0000-0006-0001-000000000002', '00000000-0000-0000-0006-000000000001', 'act_id_card', 'dialogue', '신분증을 드리겠다고 말하세요.', 'Say you will give your ID', '{"primary": "신분증 드릴게요"}'::jsonb, 2, 2),
  ('00000000-0000-0006-0002-000000000001', '00000000-0000-0000-0006-000000000002', 'act_deposit_money', 'dialogue', '돈을 입금하고 싶다고 말하세요.', 'Say you want to deposit money', '{"primary": "입금하고 싶어요"}'::jsonb, 2, 1),
  ('00000000-0000-0006-0003-000000000001', '00000000-0000-0000-0006-000000000003', 'act_send_money', 'dialogue', '송금하고 싶다고 말하세요.', 'Say you want to send money', '{"primary": "송금하고 싶어요"}'::jsonb, 2, 1);

-- Lesson 7: 병원
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence) VALUES
  ('00000000-0000-0000-0000-000000000007', 'les_hospital_007', '병원 가기', 'Hospital Visit', 'A2', 'en', 'ko', '병원에서 증상을 설명하고 진료받는 표현을 배웁니다.', 'Learn medical expressions.', 7);

INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, sequence) VALUES
  ('00000000-0000-0000-0007-000000000001', '00000000-0000-0000-0000-000000000007', 'stg_symptoms', '증상 설명', 'Symptoms', 'hospital', 1),
  ('00000000-0000-0000-0007-000000000002', '00000000-0000-0000-0000-000000000007', 'stg_pharmacy', '약국', 'Pharmacy', 'pharmacy', 2);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence) VALUES
  ('00000000-0000-0007-0001-000000000001', '00000000-0000-0000-0007-000000000001', 'act_headache', 'dialogue', '머리가 아프다고 말하세요.', 'Say you have a headache', '{"primary": "머리가 아파요"}'::jsonb, 2, 1),
  ('00000000-0000-0007-0001-000000000002', '00000000-0000-0000-0007-000000000001', 'act_fever', 'dialogue', '열이 있다고 말하세요.', 'Say you have a fever', '{"primary": "열이 있어요"}'::jsonb, 2, 2),
  ('00000000-0000-0007-0001-000000000003', '00000000-0000-0000-0007-000000000001', 'act_cough', 'dialogue', '기침이 난다고 말하세요.', 'Say you are coughing', '{"primary": "기침이 나요"}'::jsonb, 2, 3),
  ('00000000-0000-0007-0002-000000000001', '00000000-0000-0000-0007-000000000002', 'act_medicine', 'dialogue', '약을 주세요.', 'Ask for medicine', '{"primary": "약 주세요"}'::jsonb, 2, 1);

-- Lesson 8: 감정 표현
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence) VALUES
  ('00000000-0000-0000-0000-000000000008', 'les_emotions_008', '감정 표현하기', 'Expressing Emotions', 'B1', 'en', 'ko', '다양한 감정을 표현하는 방법을 배웁니다.', 'Learn to express various emotions.', 8);

INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, sequence) VALUES
  ('00000000-0000-0000-0008-000000000001', '00000000-0000-0000-0000-000000000008', 'stg_joy', '기쁨', 'Joy', 'cafe', 1),
  ('00000000-0000-0000-0008-000000000002', '00000000-0000-0000-0000-000000000008', 'stg_sad', '슬픔', 'Sadness', 'street', 2),
  ('00000000-0000-0000-0008-000000000003', '00000000-0000-0000-0000-000000000008', 'stg_apologize', '사과와 감사', 'Apology & Thanks', 'office', 3);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence) VALUES
  ('00000000-0000-0008-0001-000000000001', '00000000-0000-0000-0008-000000000001', 'act_happy', 'dialogue', '기쁘다고 말하세요.', 'Say you are happy', '{"primary": "기쁘네요"}'::jsonb, 2, 1),
  ('00000000-0000-0008-0001-000000000002', '00000000-0000-0000-0008-000000000001', 'act_excited', 'dialogue', '신난다고 말하세요.', 'Say you are excited', '{"primary": "신나요"}'::jsonb, 2, 2),
  ('00000000-0000-0008-0002-000000000001', '00000000-0000-0000-0008-000000000002', 'act_sad', 'dialogue', '슬프다고 말하세요.', 'Say you are sad', '{"primary": "슬퍼요"}'::jsonb, 2, 1),
  ('00000000-0000-0008-0003-000000000001', '00000000-0000-0000-0008-000000000003', 'act_sorry', 'dialogue', '미안하다고 말하세요.', 'Say sorry', '{"primary": "죄송해요"}'::jsonb, 2, 1),
  ('00000000-0000-0008-0003-000000000002', '00000000-0000-0000-0008-000000000003', 'act_thank_you', 'dialogue', '감사하다고 말하세요.', 'Say thank you', '{"primary": "감사합니다"}'::jsonb, 2, 2);

-- Lesson 9: 날씨와 계절
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence) VALUES
  ('00000000-0000-0000-0000-000000000009', 'les_weather_009', '날씨 이야기', 'Weather Talk', 'B1', 'en', 'ko', '날씨와 계절에 대해 이야기하는 표현을 배웁니다.', 'Learn weather expressions.', 9);

INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, sequence) VALUES
  ('00000000-0000-0000-0009-000000000001', '00000000-0000-0000-0000-000000000009', 'stg_weather', '날씨 묻기', 'Weather', 'street', 1),
  ('00000000-0000-0000-0009-000000000002', '00000000-0000-0000-0000-000000000009', 'stg_seasons', '계절', 'Seasons', 'cafe', 2);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence) VALUES
  ('00000000-0000-0009-0001-000000000001', '00000000-0000-0000-0009-000000000001', 'act_hot', 'dialogue', '덥다고 말하세요.', 'Say it is hot', '{"primary": "덥네요"}'::jsonb, 2, 1),
  ('00000000-0000-0009-0001-000000000002', '00000000-0000-0000-0009-000000000001', 'act_cold', 'dialogue', '춥다고 말하세요.', 'Say it is cold', '{"primary": "춥네요"}'::jsonb, 2, 2),
  ('00000000-0000-0009-0001-000000000003', '00000000-0000-0000-0009-000000000001', 'act_raining', 'dialogue', '비가 온다고 말하세요.', 'Say it is raining', '{"primary": "비가 와요"}'::jsonb, 2, 3),
  ('00000000-0000-0009-0002-000000000001', '00000000-0000-0000-0009-000000000002', 'act_spring', 'dialogue', '봄을 좋아한다고 말하세요.', 'Say you like spring', '{"primary": "봄을 좋아해요"}'::jsonb, 2, 1);

-- Lesson 10: 전화 통화
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence) VALUES
  ('00000000-0000-0000-0000-000000000010', 'les_phone_010', '전화하기', 'Phone Calls', 'B1', 'en', 'ko', '전화로 대화하는 기본 표현을 배웁니다.', 'Learn phone call expressions.', 10);

INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, sequence) VALUES
  ('00000000-0000-0000-0010-000000000001', '00000000-0000-0000-0000-000000000010', 'stg_calling', '전화 걸기', 'Making a Call', 'office', 1),
  ('00000000-0000-0000-0010-000000000002', '00000000-0000-0000-0000-000000000010', 'stg_message', '메시지 남기기', 'Leaving Message', 'office', 2);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence) VALUES
  ('00000000-0000-0010-0001-000000000001', '00000000-0000-0000-0010-000000000001', 'act_hello_phone', 'dialogue', '전화로 여보세요라고 하세요.', 'Say hello on phone', '{"primary": "여보세요"}'::jsonb, 2, 1),
  ('00000000-0000-0010-0001-000000000002', '00000000-0000-0000-0010-000000000001', 'act_who_speaking', 'dialogue', '누구신지 물어보세요.', 'Ask who is speaking', '{"primary": "누구세요?"}'::jsonb, 2, 2),
  ('00000000-0000-0010-0002-000000000001', '00000000-0000-0000-0010-000000000002', 'act_leave_message', 'dialogue', '메시지를 남기겠다고 하세요.', 'Say you will leave a message', '{"primary": "메시지 남기겠습니다"}'::jsonb, 3, 1);

DO $$
BEGIN
  RAISE NOTICE '중급 5종 완료 (Lessons 6-10)';
END $$;
