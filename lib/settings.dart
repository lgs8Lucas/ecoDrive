const String databaseName =  "ecoDriveDB.db"; //Criando o nome do banco de dados
const String tableName = "ecoDriveTable"; //Criando o nome da tabela do banco de dados
const String createEcoDriveTableScript = """
CREATE TABLE ecoDriveTable (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nomeViagem TEXT,
    dataViagem TEXT
);
""";