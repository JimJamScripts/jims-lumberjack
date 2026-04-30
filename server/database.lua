local db = {}

function db.init()
    -- Create companies table
    exports.ghmattimysql:execute([[
        CREATE TABLE IF NOT EXISTS companies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            funds INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    ]])

    -- Create transactions table
    exports.ghmattimysql:execute([[
        CREATE TABLE IF NOT EXISTS company_transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            company_id INTEGER,
            type TEXT,
            amount INTEGER,
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    ]])

    -- Create lumberjack logs table
    exports.ghmattimysql:execute([[
        CREATE TABLE IF NOT EXISTS lumberjack_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            identifier TEXT,
            amount INTEGER,
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    ]])
end

return db
