const String databaseName =  "ecoDriveDB.db"; //Criando o nome do banco de dados
const String tableName = "ecoDriveTable"; //Criando o nome da tabela do banco de dados
const String createEcoDriveTableScript = """
CREATE TABLE ecoDriveTable(
id INTEGER PRIMARY KEY AUTOINCREMENT,
nomeViagem TEXT,
duracaoViagem INTEGER,
tempoRPMVerde INTEGER,
dataViagem TEXT,
tipoCombustivel TEXT,
quilometragemRodada REAL,
consumoCombustivel REAL,
emissaoCarbono REAL,
avaliacaoViagem TEXT);

""";
