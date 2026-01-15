-- Lessons 4-5: 식당 & 교통
-- For Korean Together ver0.2

-- Lesson 4: 식당
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence)
VALUES (
  '00000000-0000-0000-0000-000000000004',
  'les_restaurant_004',
  '식당에서',
  'At a Restaurant',
  'A1',
  'en',
  'ko',
  '식당에서 음식을 주문하고 요청하는 표현을 배웁니다.',
  'Learn how to order food and make requests at a restaurant.',
  4
);

-- Lesson 5: 교통
INSERT INTO lessons (id, code, title_ko, title_en, level, instruction_lang, target_lang, description_ko, description_en, sequence)
VALUES (
  '00000000-0000-0000-0000-000000000005',
  'les_transport_005',
  '교통수단 이용하기',
  'Using Transportation',
  'A1',
  'en',
  'ko',
  '교통수단을 이용할 때 필요한 표현을 배웁니다.',
  'Learn essential expressions for using transportation.',
  5
);

-- ========== Lesson 4 Stages ==========
INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, sequence) VALUES
  ('00000000-0000-0000-0004-000000000001', '00000000-0000-0000-0000-000000000004', 'stg_ordering', '주문하기', 'Ordering Food', 'restaurant', 1),
  ('00000000-0000-0000-0004-000000000002', '00000000-0000-0000-0000-000000000004', 'stg_requests', '요청하기', 'Making Requests', 'restaurant', 2),
  ('00000000-0000-0000-0004-000000000003', '00000000-0000-0000-0000-000000000004', 'stg_bill', '계산하기', 'Paying the Bill', 'restaurant', 3);

-- ========== Lesson 5 Stages ==========
INSERT INTO stages (id, lesson_id, code, title_ko, title_en, scene_type, sequence) VALUES
  ('00000000-0000-0000-0005-000000000001', '00000000-0000-0000-0000-000000000005', 'stg_directions', '길 묻기', 'Asking Directions', 'street', 1),
  ('00000000-0000-0000-0005-000000000002', '00000000-0000-0000-0000-000000000005', 'stg_taxi', '택시 타기', 'Taking a Taxi', 'street', 2),
  ('00000000-0000-0000-0005-000000000003', '00000000-0000-0000-0000-000000000005', 'stg_subway', '지하철 타기', 'Taking the Subway', 'subway', 3);

-- ========== Lesson 4 Activities ==========
INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence) VALUES
  -- Ordering
  ('00000000-0000-0004-0001-000000000001', '00000000-0000-0000-0004-000000000001', 'act_order_bulgogi', 'dialogue', '불고기를 주문하세요.', 'Order bulgogi', '{"primary": "불고기 주세요"}'::jsonb, 1, 1),
  ('00000000-0000-0004-0001-000000000002', '00000000-0000-0000-0004-000000000001', 'act_two_servings', 'dialogue', '두 인분 주문하세요.', 'Order two servings', '{"primary": "두 인분 주세요"}'::jsonb, 2, 2),
  ('00000000-0000-0004-0001-000000000003', '00000000-0000-0000-0004-000000000001', 'act_menu', 'dialogue', '메뉴판을 달라고 하세요.', 'Ask for the menu', '{"primary": "메뉴판 주세요"}'::jsonb, 1, 3),
  
  -- Requests
  ('00000000-0000-0004-0002-000000000001', '00000000-0000-0000-0004-000000000002', 'act_water', 'dialogue', '물을 달라고 하세요.', 'Ask for water', '{"primary": "물 좀 주세요"}'::jsonb, 1, 1),
  ('00000000-0000-0004-0002-000000000002', '00000000-0000-0000-0004-000000000002', 'act_not_spicy', 'dialogue', '안 맵게 해달라고 하세요.', 'Ask for not spicy', '{"primary": "안 맵게 해주세요"}'::jsonb, 2, 2),
  ('00000000-0000-0004-0002-000000000003', '00000000-0000-0000-0004-000000000002', 'act_more_kimchi', 'dialogue', '김치를 더 달라고 하세요.', 'Ask for more kimchi', '{"primary": "김치 더 주세요"}'::jsonb, 1, 3),
  
  -- Bill
  ('00000000-0000-0004-0003-000000000001', '00000000-0000-0000-0004-000000000003', 'act_check', 'dialogue', '계산서를 달라고 하세요.', 'Ask for the check', '{"primary": "계산서 주세요"}'::jsonb, 1, 1),
  ('00000000-0000-0004-0003-000000000002', '00000000-0000-0000-0004-000000000003', 'act_together', 'dialogue', '같이 계산한다고 말하세요.', 'Say pay together', '{"primary": "같이 계산할게요"}'::jsonb, 2, 2),
  ('00000000-0000-0004-0003-000000000003', '00000000-0000-0000-0004-000000000003', 'act_card_payment', 'dialogue', '카드로 계산한다고 말하세요.', 'Say pay by card', '{"primary": "카드로 할게요"}'::jsonb, 1, 3);

-- ========== Lesson 5 Activities ==========
INSERT INTO activities (id, stage_id, code, activity_type, prompt_ko, prompt_en, expected_patterns, difficulty, sequence) VALUES
  -- Directions
  ('00000000-0000-0005-0001-000000000001', '00000000-0000-0000-0005-000000000001', 'act_where_subway', 'dialogue', '지하철역이 어디인지 물어보세요.', 'Ask where the subway station is', '{"primary": "지하철역이 어디예요?"}'::jsonb, 1, 1),
  ('00000000-0000-0005-0001-000000000002', '00000000-0000-0000-0005-000000000001', 'act_how_to_go', 'dialogue', '어떻게 가는지 물어보세요.', 'Ask how to get there', '{"primary": "어떻게 가요?"}'::jsonb, 1, 2),
  ('00000000-0000-0005-0001-000000000003', '00000000-0000-0000-0005-000000000001', 'act_how_far', 'dialogue', '얼마나 걸리는지 물어보세요.', 'Ask how far it is', '{"primary": "얼마나 걸려요?"}'::jsonb, 2, 3),
  
  -- Taxi
  ('00000000-0000-0005-0002-000000000001', '00000000-0000-0000-0005-000000000002', 'act_to_myeongdong', 'dialogue', '명동으로 가달라고 하세요.', 'Tell taxi to go to Myeongdong', '{"primary": "명동으로 가주세요"}'::jsonb, 1, 1),
  ('00000000-0000-0005-0002-000000000002', '00000000-0000-0000-0005-000000000002', 'act_stop_here', 'dialogue', '여기서 세워달라고 하세요.', 'Ask to stop here', '{"primary": "여기서 세워주세요"}'::jsonb, 2, 2),
  ('00000000-0000-0005-0002-000000000003', '00000000-0000-0000-0005-000000000002', 'act_how_much_taxi', 'dialogue', '택시비가 얼마인지 물어보세요.', 'Ask how much the taxi fare is', '{"primary": "얼마예요?"}'::jsonb, 1, 3),
  
  -- Subway
  ('00000000-0000-0005-0003-000000000001', '00000000-0000-0000-0005-000000000003', 'act_to_gangnam', 'dialogue', '이게 강남 가는지 물어보세요.', 'Ask if this bus/train goes to Gangnam', '{"primary": "이거 강남 가요?"}'::jsonb, 1, 1),
  ('00000000-0000-0005-0003-000000000002', '00000000-0000-0000-0005-000000000003', 'act_which_line', 'dialogue', '몇 호선인지 물어보세요.', 'Ask which line to take', '{"primary": "몇 호선이에요?"}'::jsonb, 2, 2),
  ('00000000-0000-0005-0003-000000000003', '00000000-0000-0000-0005-000000000003', 'act_transfer', 'dialogue', '어디서 갈아타는지 물어보세요.', 'Ask where to transfer', '{"primary": "어디서 갈아타요?"}'::jsonb, 2, 3);

DO $$
DECLARE
  total_lessons INT;
  total_activities INT;
BEGIN
  SELECT COUNT(*) INTO total_lessons FROM lessons;
  SELECT COUNT(*) INTO total_activities FROM activities;
  
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'ver0.2 초급 5종 완료!';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '총 Lessons: %', total_lessons;
  RAISE NOTICE '총 Activities: %', total_activities;
  RAISE NOTICE '==============================================';
END $$;
