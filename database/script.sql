----Phan he 1:
-- Tao role SYS_ADMIN
CREATE ROLE SYS_ADMIN;

--GRANT role, priviledges cho SYS_ADMIN
GRANT SELECT ON V_$sga TO SYS_ADMIN;
GRANT SELECT ON Dba_Roles TO SYS_ADMIN;
GRANT SELECT ON Dba_Users TO SYS_ADMIN;
GRANT SELECT ON Dba_Role_Privs TO SYS_ADMIN;
GRANT DROP USER TO SYS_ADMIN WITH ADMIN OPTION;
GRANT CONNECT, RESOURCE, DBA TO SYS_ADMIN WITH ADMIN OPTION;


-- Tao user
CREATE USER ADMIN_BV IDENTIFIED BY 6789;

--GRANT 1 so priviledges cho user
GRANT CREATE SESSION TO ADMIN_BV WITH ADMIN OPTION;
GRANT UNLIMITED TABLESPACE TO ADMIN_BV WITH ADMIN OPTION;

-- GRANT SYS_ADMIN cho user de l�m admin
GRANT SYS_ADMIN TO ADMIN_BV;

---Phan he 2:

----Tao cac role trong he thong
CREATE ROLE HR;
CREATE ROLE ACCOUNTING_MANAGER;
CREATE ROLE SPECIALIZE_MANAGER;
CREATE ROLE RECEPTIONIST;
CREATE ROLE FINANCE_STAFF;
CREATE ROLE ACCOUNTING_STAFF;
CREATE ROLE PHARMACIST;
CREATE ROLE DOCTOR;
CREATE ROLE PATIENT;

--Cai dat cac chinh sach 
---Bang Employees (NHANVIEN)

GRANT SELECT,INSERT,DELETE,UPDATE ON Employees TO HR;

---Xem thong tin nhan vien nhung khong xem duoc cot Emp_Basic_Salary, Emp_Allowance cua nguoi khac
CREATE OR REPLACE VIEW EXP_SALARY
AS
SELECT Emp_Id, Unit_Id,Emp_Name,Emp_Age,Emp_Address,Emp_Phone,
DECODE(Emp_Id,USER,Emp_Basic_Salary,NULL) Emp_Basic_Salary,
DECODE (Emp_Id,USER,Emp_Allowance,NULL)Emp_Allowance,
Emp_Speciality,Emp_Experience,Emp_Type          
FROM Employees;

GRANT SELECT ON EXP_SALARY TO ACCOUNTING_MANAGER,SPECIALIZE_MANAGER;

--Xem thong tin ca nhan cua nhan vien
CREATE OR REPLACE VIEW INFOR_EMPLOYEE
AS
SELECT * FROM Employees EMP
WHERE SYS_CONTEXT('userenv','session_user') = EMP.Emp_Id;

GRANT SELECT ON INFOR_EMPLOYEE TO HR, ACCOUNTING_MANAGER,  SPECIALIZE_MANAGER, 
RECEPTIONIST, FINANCE_STAFF, ACCOUNTING_STAFF, PHARMACIST, DOCTOR;

--Nhan vien ke toan chi xem va sua tren cot (Emp_Basic_Salary, Emp_Allowance)
CREATE OR REPLACE VIEW ACC_EMPLOYEE
AS
SELECT Emp_Id, Emp_Basic_Salary, Emp_Allowance FROM Employees;

GRANT SELECT ON Employees TO ACCOUNTING_STAFF;
GRANT UPDATE (Emp_Basic_Salary, Emp_Allowance) ON ACC_EMPLOYEE TO ACCOUNTING_STAFF;

--Bang Patinent (BENHNHAN)
GRANT SELECT,INSERT,DELETE,UPDATE ON Patients TO RECEPTIONIST;

--NV TAI VU XEM Patient_Id,Patient_Name,Health_Insurance_Id CUA BENH NHAN
CREATE OR REPLACE VIEW FIN_INFOR_PATIENT
AS
SELECT Patient_Id,Patient_Name,Health_Insurance_Id
FROM Patients;

GRANT SELECT ON FIN_INFOR_PATIENT TO FINANCE_STAFF;
GRANT SELECT ON Patients TO DOCTOR;

--Xem thong tin ca nhan: benh nhan
CREATE OR REPLACE VIEW INFOR_PATIENT
AS
SELECT * FROM Patients PATI
WHERE SYS_CONTEXT('userenv','session_user') = PATI.Patient_Id;

GRANT SELECT ON INFOR_PATIENT TO PATIENT;

--Bang Anamnesis (HOSOBENHAN)
GRANT SELECT ON Anamnesis TO SPECIALIZE_MANAGER;

--TIEP TAN chi xem Resp_Doctor_Id, Disease_Symptoms 
CREATE OR REPLACE VIEW RECEP_SEE_ANAMNESIS
AS
SELECT Resp_Doctor_Id, Disease_Symptoms
FROM Anamnesis;

GRANT SELECT, INSERT, UPDATE ON RECEP_SEE_ANAMNESIS TO RECEPTIONIST;

--Bac si duoc xem khi la bac si dieu tri
CREATE OR REPLACE VIEW DOC_SEE_ANAMNESIS
AS
SELECT * FROM Anamnesis ANA
WHERE SYS_CONTEXT('userenv','session_user') = ANA.Resp_Doctor_Id;

GRANT SELECT ON DOC_SEE_ANAMNESIS TO DOCTOR;

---Sua (Diagnosis, Re_Exam_Date)
GRANT UPDATE(Diagnosis, Re_Exam_Date) ON DOC_SEE_ANAMNESIS TO DOCTOR;

--Xem benh an cua minh
CREATE OR REPLACE VIEW PATI_SEE_ANAMNESIS
AS
SELECT * FROM Anamnesis ANA
WHERE SYS_CONTEXT('userenv','session_user') = ANA.Patient_Id;

GRANT SELECT ON PATI_SEE_ANAMNESIS TO PATIENT;

--Bang Departments (PHONGKHAM)
GRANT SELECT, INSERT, DELETE, UPDATE ON Departments TO HR;

--Bang Unit_Works (DONVILAMVIEC)
GRANT SELECT, INSERT, DELETE, UPDATE ON Unit_Works TO HR;

---Xem don vi lam viec cua minh
CREATE OR REPLACE VIEW INFOR_UNIT_WORK
AS
SELECT UW.Unit_Id,UW.Unit_Name 
FROM Unit_WorkS UW, Employees EMP
WHERE SYS_CONTEXT('userenv','session_user') = EMP.Emp_Id 
AND EMP.Unit_Id = UW.Unit_Id;

GRANT SELECT ON INFOR_UNIT_WORK TO HR, ACCOUNTING_MANAGER,  SPECIALIZE_MANAGER, 
RECEPTIONIST, FINANCE_STAFF, ACCOUNTING_STAFF, PHARMACIST, DOCTOR;

--Bang Shifts (CALAMVIEC)
GRANT SELECT, INSERT, DELETE, UPDATE ON Shifts TO HR;

---Xem ca lam viec cua minh
CREATE OR REPLACE VIEW INFOR_SHIFT
AS
SELECT * FROM Shifts SH
WHERE SYS_CONTEXT('userenv','session_user') = SH.Emp_Id;

GRANT SELECT ON INFOR_SHIFT TO DOCTOR;

--Bang Prescriptions (TOATHUOC)
GRANT SELECT ON Prescriptions TO SPECIALIZE_MANAGER,PHARMACIST;

---Xem toa thuoc da ke 
CREATE OR REPLACE VIEW DOC_INFOR_PRES
AS
SELECT PRES.PRES_ID,PRES.ANAMNESIS_ID,PRES.MEDICINE_ID,PRES.AMOUNT,PRES.QUANTITY_PER_DAY,PRES.NOTE 
FROM Prescriptions PRES, Anamnesis ANA
WHERE SYS_CONTEXT('userenv','session_user') = ANA.Resp_Doctor_Id
AND PRES.Anamnesis_Id  = ANA.Anamnesis_Id;

GRANT SELECT,UPDATE,INSERT ON DOC_INFOR_PRES TO DOCTOR;

--Xem toa thuoc cua minh cua benh nhan
CREATE OR REPLACE VIEW PATI_INFOR_PRES
AS
SELECT PRES.PRES_ID,PRES.ANAMNESIS_ID,PRES.MEDICINE_ID,PRES.AMOUNT,PRES.QUANTITY_PER_DAY,PRES.NOTE 
FROM Prescriptions PRES, Anamnesis ANA
WHERE SYS_CONTEXT('userenv','session_user') = ANA.Patient_Id
AND PRES.Anamnesis_Id  = ANA.Anamnesis_Id;

GRANT SELECT ON PATI_INFOR_PRES TO PATIENT;

--Bang Medicines (THUOC)
GRANT SELECT, INSERT, DELETE, UPDATE ON Medicines TO ACCOUNTING_MANAGER;
GRANT SELECT ON Medicines TO DOCTOR,PHARMACIST,FINANCE_STAFF;

--Bang Health_Exams (CHITIETKHAMSK)
GRANT SELECT ON Health_Exams TO SPECIALIZE_MANAGER;
GRANT SELECT,INSERT ON Health_Exams TO RECEPTIONIST;

GRANT UPDATE(Anamnesis_Id,Service_Id,Doctor_Id,Dep_Id) ON Health_Exams TO RECEPTIONIST;

--NV TAI VU CHI XEM Anamnesis_Id, Service_Id
CREATE OR REPLACE VIEW FIN_SEE_HEALTH_EXAMS
AS
SELECT Anamnesis_Id, Service_Id
FROM Health_Exams;

GRANT SELECT ON FIN_SEE_HEALTH_EXAMS TO FINANCE_STAFF;

--Xem chi tiet kham cua minh phu trach CUA BAC SI
CREATE OR REPLACE VIEW DOC_INFOR_HEALTH_EXAMS
AS
SELECT * FROM Health_Exams HE
WHERE SYS_CONTEXT('userenv','session_user') = HE.Doctor_Id;

GRANT SELECT ON DOC_INFOR_HEALTH_EXAMS TO DOCTOR;
GRANT UPDATE(Exam_Result) ON DOC_INFOR_HEALTH_EXAMS TO DOCTOR;

--XEM CHI TIET KHAM CUA BENH NHAN CHI XEM CUA MINH
CREATE OR REPLACE VIEW PATI_INFOR_HEALTH_EXAMS
AS
SELECT HE.EXAM_ID,HE.ANAMNESIS_ID,HE.SERVICE_ID,HE.DOCTOR_ID,HE.DEP_ID,HE.EXAM_DATE,HE.EXAM_RESULT 
FROM Health_Exams HE, Anamnesis ANA
WHERE SYS_CONTEXT('userenv','session_user') = ANA.Patient_Id
AND ANA.Anamnesis_Id = HE.Anamnesis_Id;

GRANT SELECT ON PATI_INFOR_HEALTH_EXAMS TO PATIENT;

--Bang Services (DICHVU)
GRANT SELECT, INSERT, DELETE, UPDATE ON Services TO ACCOUNTING_MANAGER;
GRANT SELECT ON Services TO DOCTOR, PATIENT,FINANCE_STAFF;

--Bang Invoices (HOADON)
GRANT SELECT, INSERT, DELETE, UPDATE ON Invoices TO ACCOUNTING_MANAGER;
GRANT SELECT ON Invoices TO FINANCE_STAFF;

---Xem hoa don 
CREATE OR REPLACE VIEW PATI_INFOR_INVOICE
AS
SELECT INV.ANAMNESIS_ID,INV.TOTAL_PRICE 
FROM Invoices INV, Anamnesis ANA
WHERE SYS_CONTEXT('userenv','session_user') = ANA.Patient_Id
AND ANA.Anamnesis_Id = INV.Anamnesis_Id;

GRANT SELECT ON PATI_INFOR_INVOICE TO PATIENT;

---Tao user
CREATE USER HR01 IDENTIFIED BY HR01;
CREATE USER HR02 IDENTIFIED BY HR02;

CREATE USER ACCOUNTING_MANAGER01 IDENTIFIED BY ACCOUNTING_MANAGER01;
CREATE USER ACCOUNTING_MANAGER02 IDENTIFIED BY ACCOUNTING_MANAGER02;

CREATE USER SPECIALIZE_MANAGER01 IDENTIFIED BY SPECIALIZE_MANAGER01;
CREATE USER SPECIALIZE_MANAGER02 IDENTIFIED BY SPECIALIZE_MANAGER02;

CREATE USER RECEPTIONIST01 IDENTIFIED BY RECEPTIONIST01;
CREATE USER RECEPTIONIST02 IDENTIFIED BY RECEPTIONIST02;

CREATE USER FINANCE_STAFF01 IDENTIFIED BY FINANCE_STAFF01;
CREATE USER FINANCE_STAFF02 IDENTIFIED BY FINANCE_STAFF02;

CREATE USER ACCOUNTING_STAFF01 IDENTIFIED BY ACCOUNTING_STAFF01;
CREATE USER ACCOUNTING_STAFF02 IDENTIFIED BY ACCOUNTING_STAFF02;

CREATE USER PHARMACIST01 IDENTIFIED BY PHARMACIST01;
CREATE USER PHARMACIST02 IDENTIFIED BY PHARMACIST02;

CREATE USER DOCTOR01 IDENTIFIED BY DOCTOR01;
CREATE USER DOCTOR02 IDENTIFIED BY DOCTOR02;

CREATE USER PATIENT01 IDENTIFIED BY PATIENT01;
CREATE USER PATIENT02 IDENTIFIED BY PATIENT02;
CREATE USER PATIENT03 IDENTIFIED BY PATIENT03;
CREATE USER PATIENT04 IDENTIFIED BY PATIENT04;

--GRANT ROLE CHO CAC USER
GRANT HR TO HR01, HR02;
GRANT ACCOUNTING_MANAGER TO ACCOUNTING_MANAGER01,ACCOUNTING_MANAGER02;
GRANT SPECIALIZE_MANAGER TO SPECIALIZE_MANAGER01,SPECIALIZE_MANAGER02;
GRANT RECEPTIONIST TO RECEPTIONIST01,RECEPTIONIST02;
GRANT FINANCE_STAFF TO FINANCE_STAFF01,FINANCE_STAFF02;
GRANT ACCOUNTING_STAFF TO ACCOUNTING_STAFF01,ACCOUNTING_STAFF02;
GRANT PHARMACIST TO PHARMACIST01,PHARMACIST02;
GRANT DOCTOR TO DOCTOR01,DOCTOR02;
GRANT PATIENT TO PATIENT01,PATIENT02,PATIENT03,PATIENT04;
