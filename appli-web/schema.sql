-- Crée la base (à exécuter une seule fois dans RDS)
CREATE DATABASE IF NOT EXISTS gestion_app
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE gestion_app;

-- Table des utilisateurs
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table des tâches
CREATE TABLE IF NOT EXISTS tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status ENUM('TODO', 'IN_PROGRESS', 'DONE') DEFAULT 'TODO',
  due_date DATE NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tasks_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;


INSERT INTO users (name, email)
VALUES ('Utilisateur Test 1', 'test1@example.com');


INSERT INTO users (name, email)
VALUES ('Utilisateur Test 2', 'test2@example.com');

INSERT INTO users (name, email)
VALUES ('Utilisateur Test 3', 'test3@example.com');

