-- Lesson 3: 쇼핑 (Shopping)
-- For Korean Together ver0.2

INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence)
VALUES (
  '00000000-0000-0000-0000-000000000003',
  'les_shopping_003',
  '쇼핑하기',
  'Shopping',
  'A1',
  'en',
  'ko',
  '쇼핑할 때 필요한 표현을 배웁니다. 가격 묻기, 크기와 색상 고르기, 결제하는 방법을 익힙니다.',
  'Learn essential shopping expressions. Practice asking prices, choosing sizes and colors, and making payments.',
  3
);

-- Stage 1: 가격 묻기
INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, objective_ko, objective_en, sequence)
VALUES (
  '00000000-0000-0000-0003-000000000001',
  '00000000-0000-0000-0000-000000000003',
  'stg_asking_price',
  '가격 묻기',
  'Asking Prices',
  'shop',
  '물건의 가격을 묻는 다양한 표현을 배웁니다.',
  'Learn various ways to ask for prices.',
  1
);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence)
VALUES
  ('00000000-0000-0003-0001-000000000001', '00000000-0000-0000-0003-000000000001', 'act_how_much', 'dialogue',
   '이 물건의 가격을 물어보세요.',
   'Ask how much this item costs.',
   '{"primary": "이거 얼마예요?", "variations": ["얼마입니까?", "가격이 어떻게 돼요?"], "formality": "neutral"}'::jsonb, 1, 1),
   
  ('00000000-0000-0003-0001-000000000002', '00000000-0000-0000-0003-000000000001', 'act_that_one', 'dialogue',
   '저 물건의 가격을 물어보세요.',
   'Ask the price of that item over there.',
   '{"primary": "저거 얼마예요?", "variations": ["저것 가격이 얼마예요?"], "formality": "neutral"}'::jsonb, 1, 2);

-- Stage 2: 크기와 색상
INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, objective_ko, objective_en, sequence)
VALUES (
  '00000000-0000-0000-0003-000000000002',
  '00000000-0000-0000-0000-000000000003',
  'stg_size_color',
  '크기와 색상 고르기',
  'Choosing Size and Color',
  'shop',
  '크기와 색상을 선택하는 표현을 배웁니다.',
  'Learn expressions for choosing sizes and colors.',
  2
);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence)
VALUES
  ('00000000-0000-0003-0002-000000000001', '00000000-0000-0000-0003-000000000002', 'act_bigger_one', 'dialogue',
   '더 큰 것이 있는지 물어보세요.',
   'Ask if there is a bigger one.',
   '{"primary": "더 큰 거 있어요?", "variations": ["큰 사이즈 있나요?", "사이즈 큰 것 있어요?"], "formality": "casual"}'::jsonb, 2, 1),
   
  ('00000000-0000-0003-0002-000000000002', '00000000-0000-0000-0003-000000000002', 'act_blue_color', 'dialogue',
   '파란색이 있는지 물어보세요.',
   'Ask if they have it in blue.',
   '{"primary": "파란색 있어요?", "variations": ["파란색으로 주세요", "파란색은 없나요?"], "formality": "casual"}'::jsonb, 2, 2),
   
  ('00000000-0000-0003-0002-000000000003', '00000000-0000-0000-0003-000000000002', 'act_try_on', 'dialogue',
   '입어봐도 되는지 물어보세요.',
   'Ask if you can try it on.',
   '{"primary": "입어봐도 돼요?", "variations": ["입어볼 수 있어요?", "피팅 가능한가요?"], "formality": "casual"}'::jsonb, 2, 3);

-- Stage 3: 결제하기
INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, objective_ko, objective_en, sequence)
VALUES (
  '00000000-0000-0000-0003-000000000003',
  '00000000-0000-0000-0000-000000000003',
  'stg_payment',
  '결제하기',
  'Making Payment',
  'shop',
  '결제 방법을 말하는 표현을 배웁니다.',
  'Learn expressions for payment methods.',
  3
);

INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence)
VALUES
  ('00000000-0000-0003-0003-000000000001', '00000000-0000-0000-0003-000000000003', 'act_by_card', 'dialogue',
   '카드로 결제하겠다고 말해보세요.',
   'Say you will pay by card.',
   '{"primary": "카드로 할게요", "variations": ["카드 결제요", "카드로 계산할게요"], "formality": "casual"}'::jsonb, 1, 1),
   
  ('00000000-0000-0003-0003-000000000002', '00000000-0000-0000-0003-000000000003', 'act_receipt', 'dialogue',
   '영수증을 달라고 말해보세요.',
   'Ask for a receipt.',
   '{"primary": "영수증 주세요", "variations": ["영수증 부탁해요", "영수증 필요해요"], "formality": "neutral"}'::jsonb, 1, 2),
   
  ('00000000-0000-0003-0003-000000000003', '00000000-0000-0000-0003-000000000003', 'act_bag', 'dialogue',
   '봉투에 넣어달라고 말해보세요.',
   'Ask them to put it in a bag.',
   '{"primary": "봉투에 넣어주세요", "variations": ["봉투 주세요", "포장해주세요"], "formality": "neutral"}'::jsonb, 2, 3);

DO $$
BEGIN
  RAISE NOTICE 'Lesson 3: 쇼핑 완료 (3 stages, 8 activities)';
END $$;
