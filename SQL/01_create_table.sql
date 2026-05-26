DROP TABLE IF EXISTS patients;

CREATE TABLE patients (
    patient_id      SERIAL PRIMARY KEY,
    age             INTEGER,
    sex             TEXT,
    bmi             NUMERIC(6, 2),
    children        INTEGER,
    smoker          TEXT,
    region          TEXT,
    charges         NUMERIC(12, 2)
);