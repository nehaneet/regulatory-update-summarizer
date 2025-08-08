-- Regulatory Update Summarizer Database Schema
-- TiDB Compatible Schema for storing regulatory updates and summaries

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS regulatory_updates
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE regulatory_updates;

-- Sources table: stores regulatory data sources
CREATE TABLE IF NOT EXISTS sources (
    source_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    url TEXT NOT NULL,
    source_type ENUM('website', 'rss', 'api', 'email') NOT NULL DEFAULT 'website',
    description TEXT,
    active BOOLEAN DEFAULT TRUE,
    last_checked TIMESTAMP NULL,
    check_frequency_hours INT DEFAULT 24,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_active (active),
    INDEX idx_last_checked (last_checked),
    INDEX idx_source_type (source_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Categories table: classification of regulatory updates
CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    parent_category_id INT NULL,
    description TEXT,
    color_code VARCHAR(7) DEFAULT '#007bff',
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    INDEX idx_parent (parent_category_id),
    INDEX idx_active (active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Regulatory updates table: main table for storing regulatory updates
CREATE TABLE IF NOT EXISTS regulatory_updates (
    update_id INT AUTO_INCREMENT PRIMARY KEY,
    source_id INT NOT NULL,
    category_id INT NULL,
    title VARCHAR(500) NOT NULL,
    content LONGTEXT NOT NULL,
    summary TEXT,
    url TEXT,
    publication_date DATE,
    effective_date DATE NULL,
    status ENUM('draft', 'published', 'archived', 'expired') DEFAULT 'published',
    priority ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    impact_level ENUM('minimal', 'moderate', 'significant', 'major') DEFAULT 'moderate',
    hash_content VARCHAR(64) NOT NULL, -- SHA-256 hash for duplicate detection
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (source_id) REFERENCES sources(source_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    INDEX idx_source (source_id),
    INDEX idx_category (category_id),
    INDEX idx_publication_date (publication_date),
    INDEX idx_effective_date (effective_date),
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_impact_level (impact_level),
    UNIQUE KEY uk_hash_content (hash_content),
    FULLTEXT INDEX ft_title_content (title, content, summary)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI summaries table: stores AI-generated summaries
CREATE TABLE IF NOT EXISTS ai_summaries (
    summary_id INT AUTO_INCREMENT PRIMARY KEY,
    update_id INT NOT NULL,
    summary_text TEXT NOT NULL,
    summary_type ENUM('executive', 'technical', 'compliance', 'impact') DEFAULT 'executive',
    ai_model VARCHAR(100) NOT NULL,
    confidence_score DECIMAL(3,2) NULL, -- 0.00 to 1.00
    key_points JSON,
    action_items JSON,
    affected_sectors JSON,
    processing_time_ms INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (update_id) REFERENCES regulatory_updates(update_id) ON DELETE CASCADE,
    INDEX idx_update (update_id),
    INDEX idx_summary_type (summary_type),
    INDEX idx_confidence_score (confidence_score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notifications table: tracks notification delivery
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    update_id INT NOT NULL,
    recipient_type ENUM('email', 'slack', 'webhook', 'sms') NOT NULL,
    recipient_address VARCHAR(500) NOT NULL,
    notification_status ENUM('pending', 'sent', 'failed', 'delivered') DEFAULT 'pending',
    sent_at TIMESTAMP NULL,
    error_message TEXT NULL,
    retry_count INT DEFAULT 0,
    max_retries INT DEFAULT 3,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (update_id) REFERENCES regulatory_updates(update_id) ON DELETE CASCADE,
    INDEX idx_update (update_id),
    INDEX idx_recipient_type (recipient_type),
    INDEX idx_status (notification_status),
    INDEX idx_sent_at (sent_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User subscriptions table: manages user notification preferences
CREATE TABLE IF NOT EXISTS user_subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    user_email VARCHAR(255) NOT NULL,
    source_id INT NULL, -- NULL means all sources
    category_id INT NULL, -- NULL means all categories
    priority_threshold ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    notification_frequency ENUM('immediate', 'daily', 'weekly') DEFAULT 'daily',
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (source_id) REFERENCES sources(source_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE,
    INDEX idx_user_email (user_email),
    INDEX idx_source (source_id),
    INDEX idx_category (category_id),
    INDEX idx_active (active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Search queries log table: tracks user searches for analytics
CREATE TABLE IF NOT EXISTS search_queries (
    query_id INT AUTO_INCREMENT PRIMARY KEY,
    query_text VARCHAR(1000) NOT NULL,
    user_ip VARCHAR(45), -- IPv6 support
    results_count INT DEFAULT 0,
    execution_time_ms INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_query_text (query_text(100)),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- System configuration table
CREATE TABLE IF NOT EXISTS system_config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert initial data

-- Default categories
INSERT IGNORE INTO categories (name, description, color_code) VALUES
('Financial Services', 'Banking, investment, and financial regulations', '#28a745'),
('Healthcare', 'Medical device, pharmaceutical, and healthcare regulations', '#dc3545'),
('Environmental', 'Environmental protection and sustainability regulations', '#20c997'),
('Technology', 'Data privacy, cybersecurity, and technology regulations', '#6f42c1'),
('Energy', 'Energy sector and utility regulations', '#fd7e14'),
('Transportation', 'Aviation, maritime, and ground transportation regulations', '#6610f2'),
('Consumer Protection', 'Consumer rights and protection regulations', '#e83e8c'),
('Employment', 'Labor laws and employment regulations', '#17a2b8');

-- Sample data sources
INSERT IGNORE INTO sources (name, url, source_type, description) VALUES
('SEC - Securities and Exchange Commission', 'https://www.sec.gov/news/pressreleases', 'website', 'US Securities and Exchange Commission press releases'),
('FDA - Food and Drug Administration', 'https://www.fda.gov/news-events/fda-newsroom/press-announcements', 'website', 'FDA press announcements'),
('EPA - Environmental Protection Agency', 'https://www.epa.gov/newsroom', 'website', 'EPA newsroom and updates'),
('Federal Register', 'https://www.federalregister.gov/', 'website', 'Official journal of the US government');

-- System configuration defaults
INSERT IGNORE INTO system_config (config_key, config_value, description) VALUES
('ai_model_primary', 'gpt-4', 'Primary AI model for summarization'),
('ai_model_backup', 'claude-3', 'Backup AI model'),
('max_summary_length', '500', 'Maximum character length for summaries'),
('notification_retry_hours', '24', 'Hours between notification retries'),
('content_retention_days', '365', 'Days to retain regulatory update content'),
('check_frequency_default', '6', 'Default check frequency in hours for new sources');

-- Create views for common queries

-- Recent updates view
CREATE OR REPLACE VIEW recent_updates AS
SELECT 
    ru.update_id,
    ru.title,
    ru.summary,
    ru.publication_date,
    ru.priority,
    ru.impact_level,
    s.name as source_name,
    c.name as category_name,
    c.color_code
FROM regulatory_updates ru
LEFT JOIN sources s ON ru.source_id = s.source_id
LEFT JOIN categories c ON ru.category_id = c.category_id
WHERE ru.status = 'published'
ORDER BY ru.publication_date DESC, ru.created_at DESC;

-- High priority updates view
CREATE OR REPLACE VIEW high_priority_updates AS
SELECT 
    ru.update_id,
    ru.title,
    ru.summary,
    ru.publication_date,
    ru.effective_date,
    ru.priority,
    ru.impact_level,
    s.name as source_name,
    c.name as category_name
FROM regulatory_updates ru
LEFT JOIN sources s ON ru.source_id = s.source_id
LEFT JOIN categories c ON ru.category_id = c.category_id
WHERE ru.status = 'published' 
    AND ru.priority IN ('high', 'critical')
ORDER BY 
    CASE ru.priority 
        WHEN 'critical' THEN 1 
        WHEN 'high' THEN 2 
        ELSE 3 
    END,
    ru.publication_date DESC;

-- Summary statistics view
CREATE OR REPLACE VIEW update_statistics AS
SELECT 
    COUNT(*) as total_updates,
    COUNT(CASE WHEN status = 'published' THEN 1 END) as published_updates,
    COUNT(CASE WHEN priority = 'critical' THEN 1 END) as critical_updates,
    COUNT(CASE WHEN priority = 'high' THEN 1 END) as high_priority_updates,
    COUNT(CASE WHEN publication_date >= CURDATE() - INTERVAL 7 DAY THEN 1 END) as updates_last_week,
    COUNT(CASE WHEN publication_date >= CURDATE() - INTERVAL 30 DAY THEN 1 END) as updates_last_month
FROM regulatory_updates;

-- Commit the transaction
COMMIT;

-- Display setup completion message
SELECT 'Regulatory Update Summarizer database schema created successfully!' as message;
