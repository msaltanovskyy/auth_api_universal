-- Включение расширения для генерации UUID (если еще не включено)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Заполнение таблицы me
INSERT INTO me (me_id, firstname, lastname, datebirth) VALUES
(uuid_generate_v4(), 'Иван', 'Иванов', '1990-05-15'),
(uuid_generate_v4(), 'Мария', 'Петрова', '1985-12-03'),
(uuid_generate_v4(), 'Алексей', 'Сидоров', '1992-08-20'),
(uuid_generate_v4(), 'Екатерина', 'Смирнова', '1988-03-10'),
(uuid_generate_v4(), 'Дмитрий', 'Кузнецов', '1995-11-25'),
(uuid_generate_v4(), 'Ольга', 'Васильева', '1991-07-18'),
(uuid_generate_v4(), 'Сергей', 'Попов', '1987-09-30'),
(uuid_generate_v4(), 'Анна', 'Новикова', '1993-02-14'),
(uuid_generate_v4(), 'Павел', 'Федоров', '1989-06-22'),
(uuid_generate_v4(), 'Наталья', 'Морозова', '1994-04-05');

-- Заполнение таблицы auth_user
INSERT INTO auth_user (auth_id, email, password_hash, is_active, is_verified, me_id, created_at, last_online) 
SELECT 
    uuid_generate_v4(),
    CASE 
        WHEN firstname = 'Иван' THEN 'ivan@example.com'
        WHEN firstname = 'Мария' THEN 'maria@example.com'
        WHEN firstname = 'Алексей' THEN 'alexey@example.com'
        WHEN firstname = 'Екатерина' THEN 'ekaterina@example.com'
        WHEN firstname = 'Дмитрий' THEN 'dmitry@example.com'
        WHEN firstname = 'Ольга' THEN 'olga@example.com'
        WHEN firstname = 'Сергей' THEN 'sergey@example.com'
        WHEN firstname = 'Анна' THEN 'anna@example.com'
        WHEN firstname = 'Павел' THEN 'pavel@example.com'
        WHEN firstname = 'Наталья' THEN 'natalya@example.com'
    END,
    -- Хеши паролей (все пароли: "password123")
    '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
    TRUE,
    TRUE,
    me_id,
    NOW() - INTERVAL '30 days',
    NOW() - INTERVAL '1 day' + (random() * INTERVAL '23 hours')
FROM me;

-- Заполнение таблицы role
INSERT INTO role (role_id, name, created_at) VALUES
(uuid_generate_v4(), 'admin', NOW()),
(uuid_generate_v4(), 'user', NOW()),
(uuid_generate_v4(), 'moderator', NOW()),
(uuid_generate_v4(), 'guest', NOW());

-- Заполнение таблицы permission
INSERT INTO permission (permission_id, name) VALUES
(uuid_generate_v4(), 'create_user'),
(uuid_generate_v4(), 'read_user'),
(uuid_generate_v4(), 'update_user'),
(uuid_generate_v4(), 'delete_user'),
(uuid_generate_v4(), 'create_post'),
(uuid_generate_v4(), 'read_post'),
(uuid_generate_v4(), 'update_post'),
(uuid_generate_v4(), 'delete_post'),
(uuid_generate_v4(), 'manage_roles'),
(uuid_generate_v4(), 'view_reports');

-- Связывание ролей с правами
INSERT INTO role_permission (role_id, permission_id)
SELECT 
    r.role_id,
    p.permission_id
FROM role r
CROSS JOIN permission p
WHERE 
    (r.name = 'admin' AND p.name IN ('create_user', 'read_user', 'update_user', 'delete_user', 'create_post', 'read_post', 'update_post', 'delete_post', 'manage_roles', 'view_reports'))
    OR (r.name = 'moderator' AND p.name IN ('read_user', 'update_user', 'create_post', 'read_post', 'update_post', 'delete_post', 'view_reports'))
    OR (r.name = 'user' AND p.name IN ('read_user', 'create_post', 'read_post', 'update_post', 'delete_post'))
    OR (r.name = 'guest' AND p.name IN ('read_post'));

-- Назначение ролей пользователям
INSERT INTO user_role (user_role_id, role_id, auth_id)
SELECT 
    uuid_generate_v4(),
    r.role_id,
    au.auth_id
FROM auth_user au
CROSS JOIN role r
WHERE 
    (au.email = 'ivan@example.com' AND r.name = 'admin')
    OR (au.email = 'maria@example.com' AND r.name = 'moderator')
    OR (au.email = 'alexey@example.com' AND r.name = 'moderator')
    OR (au.email IN ('ekaterina@example.com', 'dmitry@example.com', 'olga@example.com', 'sergey@example.com', 'anna@example.com', 'pavel@example.com', 'natalya@example.com') AND r.name = 'user');

-- Создание сессий для пользователей
INSERT INTO auth_session (session_id, auth_id, refresh_token, ip_address, user_agent, created_at, expires_at, revoked)
SELECT 
    uuid_generate_v4(),
    au.auth_id,
    -- Пример refresh token (в реальной системе это должен быть хеш)
    'refresh_token_' || substr(md5(random()::text), 1, 20),
    '192.168.1.' || floor(random() * 255 + 1)::text,
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    NOW() - INTERVAL '1 hour',
    NOW() + INTERVAL '7 days',
    FALSE
FROM auth_user au
WHERE au.email IN ('ivan@example.com', 'maria@example.com', 'alexey@example.com');

-- Обновление даты рождения для тестирования представления birthday_today
UPDATE me 
SET datebirth = CURRENT_DATE 
WHERE firstname = 'Иван';

-- Обновление времени последнего онлайна для тестирования представления online_today
UPDATE auth_user 
SET last_online = NOW() - INTERVAL '1 hour'
WHERE email IN ('ivan@example.com', 'maria@example.com');