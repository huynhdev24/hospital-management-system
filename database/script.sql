----Phan he 1:
CONNECT SYS;
-- Tao role SYS_ADMIN
CREATE ROLE SYS_ADMIN;

--GRANT role, priviledges cho SYS_ADMIN
GRANT SELECT ON V_$sga TO SYS_ADMIN;
GRANT SELECT ON Dba_Roles TO SYS_ADMIN;
GRANT SELECT ON Dba_Users TO SYS_ADMIN;
GRANT SELECT ON Dba_Role_Privs TO SYS_ADMIN ;
GRANT DROP USER TO SYS_ADMIN WITH ADMIN OPTION;
GRANT GRANT ANY ROLE, GRANT ANY PRIVILEGE TO SYS_ADMIN WITH ADMIN OPTION;
GRANT CONNECT, RESOURCE, DBA TO SYS_ADMIN WITH ADMIN OPTION;

-- Tao user
CREATE USER ADMIN_BV IDENTIFIED BY 6789;
GRANT SELECT ON Dba_Role_Privs TO ADMIN_BV WITH GRANT OPTION;

--GRANT 1 so priviledges cho user
GRANT CREATE SESSION TO ADMIN_BV WITH ADMIN OPTION;
GRANT UNLIMITED TABLESPACE TO ADMIN_BV WITH ADMIN OPTION;

--GRANT SYS_ADMIN cho user de lam admin
GRANT SYS_ADMIN TO ADMIN_BV;

GRANT CREATE PROCEDURE TO ADMIN_BV;

-- DBMS_RLS phai grant quyen THUC THI vi DBMS_RLS khong duoc gan cho moi nguoi dung
GRANT EXECUTE ON DBMS_RLS TO ADMIN_BV; ---CONNECT SYS 

---CAP QUYEN DE ADMIN_BV KHONG BI ANH HUONG BOI POLICY FUNCTION
GRANT EXEMPT ACCESS POLICY TO ADMIN_BV; ---CONNECT SYS 
---Phan he 2:
CONNECT ADMIN_BV;
----Tao cac role trong he thong
CREATE ROLE HR_MANAGER;
CREATE ROLE ACCOUNTING_MANAGER;
CREATE ROLE SPECIALIZE_MANAGER;
CREATE ROLE RECEPTIONIST;
CREATE ROLE FINANCE_STAFF;
CREATE ROLE ACCOUNTING_STAFF;
CREATE ROLE PHARMACIST;
CREATE ROLE DOCTOR;
CREATE ROLE PATIENT;


---Tao user trong he thong
CREATE USER DIRECTOR IDENTIFIED BY DIRECTOR;
CREATE USER HR_MANAGER00 IDENTIFIED BY HR_MANAGER00;
---Chi nhanh 01
CREATE USER HR_MANAGER01 IDENTIFIED BY HR_MANAGER01;
CREATE USER ACCOUNTING_MANAGER01 IDENTIFIED BY ACCOUNTING_MANAGER01;
CREATE USER SPECIALIZE_MANAGER01 IDENTIFIED BY SPECIALIZE_MANAGER01;
CREATE USER RECEPTIONIST01 IDENTIFIED BY RECEPTIONIST01;
CREATE USER FINANCE_STAFF01 IDENTIFIED BY FINANCE_STAFF01;
CREATE USER ACCOUNTING_STAFF01 IDENTIFIED BY ACCOUNTING_STAFF01;
CREATE USER PHARMACIST01 IDENTIFIED BY PHARMACIST01;
CREATE USER DOCTOR01 IDENTIFIED BY DOCTOR01;
CREATE USER PATIENT01 IDENTIFIED BY PATIENT01;

---Chi nhanh 02
CREATE USER HR_MANAGER03 IDENTIFIED BY HR_MANAGER03;
CREATE USER ACCOUNTING_MANAGER03 IDENTIFIED BY ACCOUNTING_MANAGER03;
CREATE USER SPECIALIZE_MANAGER03 IDENTIFIED BY SPECIALIZE_MANAGER03;
CREATE USER RECEPTIONIST03 IDENTIFIED BY RECEPTIONIST03;
CREATE USER FINANCE_STAFF03 IDENTIFIED BY FINANCE_STAFF03;
CREATE USER ACCOUNTING_STAFF03 IDENTIFIED BY ACCOUNTING_STAFF03;
CREATE USER PHARMACIST03 IDENTIFIED BY PHARMACIST03;
CREATE USER DOCTOR04 IDENTIFIED BY DOCTOR04;

--GRANT ROLE CHO CAC USER
GRANT HR_MANAGER TO HR_MANAGER01, HR_MANAGER00, DIRECTOR, HR_MANAGER03;
GRANT ACCOUNTING_MANAGER TO ACCOUNTING_MANAGER01, ACCOUNTING_MANAGER03;
GRANT SPECIALIZE_MANAGER TO SPECIALIZE_MANAGER01, SPECIALIZE_MANAGER03;
GRANT RECEPTIONIST TO RECEPTIONIST01,RECEPTIONIST03;
GRANT FINANCE_STAFF TO FINANCE_STAFF01,FINANCE_STAFF03;
GRANT ACCOUNTING_STAFF TO ACCOUNTING_STAFF01, ACCOUNTING_STAFF03;
GRANT PHARMACIST TO PHARMACIST01, PHARMACIST03;
GRANT DOCTOR TO DOCTOR01, DOCTOR04;
GRANT PATIENT TO PATIENT01;

GRANT CREATE SESSION TO HR_MANAGER, ACCOUNTING_MANAGER,  SPECIALIZE_MANAGER, 
RECEPTIONIST, FINANCE_STAFF, ACCOUNTING_STAFF, PHARMACIST, DOCTOR, PATIENT;


--Cai dat cac chinh sach 
----==========================================---------
-----Bang Employees (NHANVIEN)
---==========================================----------
-----DAC + RBAC
-- NHAN VIEN QUAN LY HR DUOC THUC HIEN MOI THAO TAC TREN BANG NHAN VIEN
GRANT SELECT,INSERT,DELETE,UPDATE ON EMPLOYEES TO HR_MANAGER;

GRANT SELECT ON EMPLOYEES TO HR_MANAGER, ACCOUNTING_MANAGER,  SPECIALIZE_MANAGER, 
RECEPTIONIST, FINANCE_STAFF, ACCOUNTING_STAFF, PHARMACIST, DOCTOR;
-- NHAN VIEN KE TOAN UPDATE DUOC TREN COT Emp_Basic_Salary, Emp_Allowance
GRANT UPDATE(Emp_Basic_Salary, Emp_Allowance) ON EMPLOYEES TO ACCOUNTING_STAFF;
---------------------------------------------------------------------------------
----VPD POLICY
-- DBMS_RLS phai grant quyen THUC THI vi DBMS_RLS khong duoc gan cho moi nguoi dung
GRANT EXECUTE ON DBMS_RLS TO ADMIN_BV; ---CONNECT SYS 
---CAP QUYEN DE ADMIN_BV KHONG BI ANH HUONG BOI POLICY FUNCTION
GRANT EXEMPT ACCESS POLICY TO ADMIN_BV; ---CONNECT SYS

---**) Nhan vien chi xem duoc thong tin ca nhan cua minh
---tru QUAN LY NHAN SU, QUAN LY TAI VU, QUAN LY CHUYEN MON VA NHAN VIEN KE TOAN

--XEM THONG TIN CA NHAN
--TAO 1 PL/SOL FUNCTION
CREATE OR REPLACE FUNCTION VPD_EMPLOYEES (
    P_SCHEMA   IN VARCHAR2 DEFAULT NULL,
    P_OBJECT   IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
    AS 
    BEGIN
    IF (USER LIKE '%DIRECTOR%' OR USER LIKE '%MANAGER%' OR USER LIKE 'ACCOUNTING_STAFF%') THEN
        RETURN '';
    END IF;
    RETURN 'EMP_ID = USER';
    END;
--DUNG THU TUC ADD_POLICY TRONG package DBMS_RLS
BEGIN
DBMS_RLS.ADD_POLICY 
(OBJECT_SCHEMA   => 'ADMIN_BV',
OBJECT_NAME      => 'EMPLOYEES',
POLICY_NAME      => 'VPD_EMP_POLICY',
POLICY_FUNCTION  => 'VPD_EMPLOYEES',
STATEMENT_TYPES   => 'SELECT');
END;

--Quan ly tai vu va chuyen mon xem thong tin nhan vien 
--nhung khong xem duoc cot Emp_Basic_Salary, Emp_Allowance
--TAO 1 PL/SOL FUNCTION
CREATE OR REPLACE FUNCTION VPD_EMPLOYEES1 (
    P_SCHEMA   IN VARCHAR2 DEFAULT NULL,
    P_OBJECT   IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
    AS 
    BEGIN
    IF (USER LIKE 'ACCOUNTING_MANAGER%' OR USER LIKE 'SPECIALIZE_MANAGER%') THEN
    RETURN 'EMP_ID = USER';
    END IF;
    RETURN '';
    END;
--DUNG THU TUC ADD_POLICY TRONG package DBMS_RLS
BEGIN
DBMS_RLS.ADD_POLICY 
(OBJECT_SCHEMA   => 'ADMIN_BV',
OBJECT_NAME      => 'EMPLOYEES',
POLICY_NAME      => 'VPD_EMP_POLICY1',
POLICY_FUNCTION  => 'VPD_EMPLOYEES1',
STATEMENT_TYPES   => 'SELECT',
SEC_RELEVANT_COLS  => 'Emp_Basic_Salary, Emp_Allowance',
SEC_RELEVANT_COLS_OPT => DBMS_RLS.ALL_ROWS);
END;

---------===============================================-------
---------Bang Patinent (BENHNHAN)
-------================================================--------
--DAC + RBAC
--Nhan vien tiep tan va dieu phoi xem,them,xoa,sua tren bang benh nhan
GRANT SELECT,INSERT,DELETE,UPDATE ON Patients TO RECEPTIONIST;
--Nhan vien tai vu va bac si xem bang benh nhan
GRANT SELECT ON Patients TO FINANCE_STAFF, DOCTOR, PATIENT;

---VPD POLICY
--Xem thong tin ca nhan: benh nhan
--tru NHAN VIEN TIEP TAN VA DIEU PHOI, NHAN VIEN TAI VU VA BAC SI
---Cai dat chinh sach bao mat voi VPD tren view
---Benh nhan chi xem thong tin ca nhan (VPD tren view)
--TAO 1 PL/SOL FUNCTION
CREATE OR REPLACE FUNCTION VPD_PATIENTS(
    P_SCHEMA   IN VARCHAR2 DEFAULT NULL,
    P_OBJECT   IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
    AS 
    BEGIN
    IF (USER LIKE 'RECEPTIONIST%' OR USER LIKE 'FINANCE_STAFF%' OR USER LIKE 'DOCTOR%') THEN
    RETURN '';
    END IF;
    RETURN 'PATIENT_ID = USER';
    END;
--DUNG THU TUC ADD_POLICY TRONG package DBMS_RLS
BEGIN
DBMS_RLS.ADD_POLICY 
(OBJECT_SCHEMA   => 'ADMIN_BV',
OBJECT_NAME      => 'PATIENTS',
POLICY_NAME      => 'VPD_PATI_POLICY',
POLICY_FUNCTION  => 'VPD_PATIENTS',
STATEMENT_TYPES   => 'SELECT');
END;

----=====================================-------------
-------Bang Anamnesis (HOSOBENHAN)
----=====================================-------------
----DAC + RBAC
GRANT SELECT ON Anamnesis TO SPECIALIZE_MANAGER,RECEPTIONIST, DOCTOR, PATIENT;
GRANT INSERT(Anamnesis_Id, Patient_Id, Exam_Date, Coordinator_Id, Disease_Symptoms, Resp_Doctor_Id) ON Anamnesis TO RECEPTIONIST;
GRANT UPDATE(Diagnosis, Re_Exam_Date, Note) ON ANAMNESIS TO DOCTOR;

------VPD POLICY
---**) Bac si chi xem duoc nhung ho so benh nhan cua minh dieu tri 
----va BENH NHAN CHI XEM HO SO CUA MINH
---XEM HO SO BENH NHAN
--TAO 1 PL/SOL FUNCTION
CREATE OR REPLACE FUNCTION VPD_ANAMNESIS(
    P_SCHEMA   IN VARCHAR2,
    P_OBJECT   IN VARCHAR2)
    RETURN VARCHAR2
    AS 
    BEGIN
    IF (USER LIKE 'SPECIALIZE_MANAGER%' OR USER LIKE 'RECEPTIONIST%') THEN
    RETURN '';
    END IF;
    RETURN 'Resp_Doctor_Id = USER OR Patient_Id = USER';
    END;
--DUNG THU TUC ADD_POLICY TRONG package DBMS_RLS
BEGIN
DBMS_RLS.ADD_POLICY 
(OBJECT_SCHEMA   => 'ADMIN_BV',
OBJECT_NAME      => 'ANAMNESIS',
POLICY_NAME      => 'VPD_ANA_POLICY',
POLICY_FUNCTION  => 'VPD_ANAMNESIS');
END;
-------==========================================
--------Bang Departments (PHONGKHAM)
------============================================
---DAC + RBAC
GRANT SELECT ON Departments TO HR_MANAGER, ACCOUNTING_MANAGER, SPECIALIZE_MANAGER;
GRANT INSERT, DELETE, UPDATE ON Departments TO HR_MANAGER;

-------==========================================
--------Bang Unit_Works (DONVILAMVIEC)
-------==========================================
---DAC + RBAC
---Quan ly nhan su xem,them, xoa, sua tren bang don vi lam viec
GRANT SELECT, INSERT, DELETE, UPDATE ON UNIT_WORKS TO HR_MANAGER;

----VIEW 
---Nhan vien chi xem don vi lam viec cua minh
CREATE OR REPLACE VIEW VIEW_UNIT_WORK
AS
SELECT UW.UNIT_ID, UW.UNIT_NAME FROM Unit_Works UW, Employees Emp
WHERE UW.UNIT_ID = Emp.Unit_Id AND EMP_ID = USER;

GRANT SELECT ON VIEW_UNIT_WORK TO HR_MANAGER, ACCOUNTING_MANAGER,  SPECIALIZE_MANAGER, 
RECEPTIONIST, FINANCE_STAFF, ACCOUNTING_STAFF, PHARMACIST, DOCTOR;

-------==========================================
--------Bang Shifts (CALAMVIEC)
-------==========================================
---DAC + RBAC
--Quan ly nhan su xem,them,xoa,sua bang Shifts
GRANT SELECT, INSERT, DELETE, UPDATE ON SHIFTS TO HR_MANAGER;
GRANT SELECT ON SHIFTS TO ACCOUNTING_MANAGER,  SPECIALIZE_MANAGER, 
RECEPTIONIST, FINANCE_STAFF, ACCOUNTING_STAFF, PHARMACIST, DOCTOR;

---VPD POLICY
---Nhan vien chi xem ca lam viec cua minh
CREATE OR REPLACE FUNCTION VPD_SHIFTS (
    P_SCHEMA   IN VARCHAR2 DEFAULT NULL,
    P_OBJECT   IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
    AS 
    BEGIN
    IF (USER LIKE 'HR_MANAGER%') THEN
    RETURN '';
    END IF;
    RETURN 'Emp_Id = USER' ;
    END;
--DUNG THU TUC ADD_POLICY TRONG package DBMS_RLS
BEGIN
DBMS_RLS.ADD_POLICY 
(OBJECT_SCHEMA   => 'ADMIN_BV',
OBJECT_NAME      => 'SHIFTS',
POLICY_NAME      => 'VPD_SHIFT_POLICY',
POLICY_FUNCTION  => 'VPD_SHIFTS');
END;

-------==========================================
-------Bang Prescriptions (TOATHUOC)
-------==========================================
---DAC + RBAC
--Quan ly chuyen mon va nhan vien ban thuoc co the xem 
GRANT SELECT ON Prescriptions TO SPECIALIZE_MANAGER,PHARMACIST;
GRANT INSERT, UPDATE ON Prescriptions TO DOCTOR; 

---VIEW
---BAC SI chi xem toa thuoc da ke 
CREATE OR REPLACE VIEW VIEW_PRES
AS
SELECT PRES.PRES_ID,PRES.ANAMNESIS_ID,PRES.MEDICINE_ID,PRES.AMOUNT,PRES.QUANTITY_PER_DAY,PRES.NOTE 
FROM Prescriptions PRES, Anamnesis ANA
WHERE SYS_CONTEXT('userenv','session_user') = ANA.Resp_Doctor_Id
AND PRES.Anamnesis_Id  = ANA.Anamnesis_Id;

GRANT SELECT,UPDATE,INSERT ON VIEW_PRES TO DOCTOR;

--Benh nhan chi xem toa thuoc cua minh
CREATE OR REPLACE VIEW VIEW_PRES1
AS
SELECT PRES.PRES_ID,PRES.ANAMNESIS_ID,PRES.MEDICINE_ID,PRES.AMOUNT,PRES.QUANTITY_PER_DAY,PRES.NOTE 
FROM Prescriptions PRES, Anamnesis ANA
WHERE SYS_CONTEXT('userenv','session_user') = ANA.Patient_Id
AND PRES.Anamnesis_Id  = ANA.Anamnesis_Id;

GRANT SELECT ON VIEW_PRES1 TO PATIENT;

-------==========================================
-------Bang Medicines (THUOC)
-------==========================================
---DAC + RBAC
GRANT SELECT, INSERT, DELETE, UPDATE ON Medicines TO ACCOUNTING_MANAGER;
GRANT SELECT ON Medicines TO DOCTOR,PHARMACIST,FINANCE_STAFF;

-------==========================================
-------Bang Health_Exams (CHITIETKHAMSK)
-------==========================================
---DAC + RBAC
GRANT SELECT ON Health_Exams TO SPECIALIZE_MANAGER;
GRANT SELECT ON Health_Exams TO RECEPTIONIST, DOCTOR;
GRANT INSERT(Exam_Id,Anamnesis_Id,Service_Id,Doctor_Id,Dep_Id,Exam_Date) ON Health_Exams TO RECEPTIONIST;
GRANT UPDATE(Exam_Id,Anamnesis_Id,Service_Id,Doctor_Id,Dep_Id) ON Health_Exams TO RECEPTIONIST;
GRANT UPDATE(Exam_Result) ON Health_Exams TO DOCTOR;

---VPD POLICY
--Xem chi tiet kham cua minh phu trach CUA BAC SI
CREATE OR REPLACE FUNCTION VPD_HEALTH_EXAM (
    P_SCHEMA   IN VARCHAR2 DEFAULT NULL,
    P_OBJECT   IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
    AS 
    BEGIN
    IF (USER LIKE 'SPECIALIZE_MANAGER%' OR USER LIKE 'RECEPTIONIST%' OR USER LIKE 'FINANCE_STAFF%' OR USER LIKE 'PATIENT%') THEN
    RETURN '';
    END IF;
        RETURN 'Doctor_Id = USER' ;
    END;
--DUNG THU TUC ADD_POLICY TRONG package DBMS_RLS
BEGIN
DBMS_RLS.ADD_POLICY 
(OBJECT_SCHEMA   => 'ADMIN_BV',
OBJECT_NAME      => 'Health_Exams',
POLICY_NAME      => 'VPD_HEALTH_POLICY',
POLICY_FUNCTION  => 'VPD_HEALTH_EXAM',
STATEMENT_TYPES  => 'SELECT,UPDATE',
UPDATE_CHECK     => TRUE);
END;

---VIEW
--NV TAI VU CHI XEM Anamnesis_Id, Service_Id
CREATE OR REPLACE VIEW VIEW_HEALTH_EXAM
AS
SELECT Anamnesis_Id, Service_Id FROM Health_Exams;

GRANT SELECT ON VIEW_HEALTH_EXAM TO FINANCE_STAFF;

--Benh nhan chi xem chi tiet kham cua minh
CREATE OR REPLACE VIEW VIEW_HEALTH_EXAMS1
AS
SELECT HE.EXAM_ID,HE.ANAMNESIS_ID,HE.SERVICE_ID,HE.DOCTOR_ID,HE.DEP_ID,HE.EXAM_DATE,HE.EXAM_RESULT 
FROM Health_Exams HE, Anamnesis ANA
WHERE SYS_CONTEXT('userenv','session_user') = ANA.Patient_Id
AND ANA.Anamnesis_Id = HE.Anamnesis_Id;

GRANT SELECT ON VIEW_HEALTH_EXAMS1 TO PATIENT;

-------==========================================
---------Bang Services (DICHVU)
-------==========================================
--DAC + RBAC
GRANT SELECT, INSERT, DELETE, UPDATE ON Services TO ACCOUNTING_MANAGER;
GRANT SELECT ON Services TO DOCTOR, PATIENT,FINANCE_STAFF;

-------==========================================
--------Bang Invoices (HOADON)
-------==========================================
---DAC + RBAC
GRANT SELECT, INSERT, DELETE, UPDATE ON Invoices TO ACCOUNTING_MANAGER;
GRANT SELECT ON Invoices TO FINANCE_STAFF;

---VIEW
---Benh nhan chi xem hoa don cua minh
CREATE OR REPLACE VIEW VIEW_INVOICE
AS
SELECT INV.ANAMNESIS_ID,INV.TOTAL_PRICE 
FROM Invoices INV, Anamnesis ANA
WHERE SYS_CONTEXT('userenv','session_user') = ANA.Patient_Id
AND ANA.Anamnesis_Id = INV.Anamnesis_Id;

GRANT SELECT ON VIEW_INVOICE TO PATIENT;

--------==========================================------------
---Chinh sach bao mat voi MAC/OLS
-------===================--------
--------Cai dat OLS-------
-------===================--------
CONNECT SYS;
---Kiem tra OLS da duoc kich hoat hay chua - FALSE: chua kich hoat OLS
SELECT STATUS FROM DBA_OLS_STATUS WHERE NAME = 'OLS_CONFIGURE_STATUS'; ---FALSE
---Neu FALSE thi kich hoat OLS
EXEC LBACSYS.CONFIGURE_OLS;
EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
--Ket noi user sys voi quyen SYSOPER
CONNECT SYS AS SYSOPER;
---Khoi dong lai csdl
SHUTDOWN IMMEDIATE
STARTUP
---Kiem tra OLS da duoc kich hoat hay chua - TRUE: da kich hoat OLS
SELECT STATUS FROM DBA_OLS_STATUS WHERE NAME = 'OLS_CONFIGURE_STATUS';

---Kich hoat tai khoan LBACSYS -- Tai khoan dung de tao cac chinh sach
CONN SYS;
ALTER USER LBACSYS IDENTIFIED BY LBACSYS ACCOUNT UNLOCK;

/*
? Quy trinh co ban de hien thuc mot chinh sach OLS gom 5 buoc nhu sau:
? B1: Tao chinh sach OLS.
? B2: Dinh nghia cac thanh phan ma mot label thuoc chinh sach tren co the co.
? B3: Tao cac nhan du lieu that su ma ban muon dung.
? B4: Gan chinh sach tren cho cac table hoac schema ma ban muon bao ve.
? B5: Gan cac gioi han quyen, cac nhan nguoi dung hoac cac quyen truy xuat dac biet cho nhung nguoi dung lien quan.*/

-------===========================--------
--------B1: Tao chinh sach OLS-------
-------===========================--------
---Ket noi tai khoan LBACSYS
CONN LBACSYS;
---Tao chinh sach OLS do LBACSYS tao va gan quyen
EXECUTE SA_SYSDBA.CREATE_POLICY('ACCESS_EMPLOYEES','OLS_EMPLOYEE');
---Cap quyen quan ly policy cho ADMIN_BV
GRANT ACCESS_EMPLOYEES_DBA TO ADMIN_BV;
-- Quyen tao ra cac thanh phan cua label
GRANT EXECUTE ON SA_COMPONENTS TO ADMIN_BV;
-- Quyen tao cac label
GRANT EXECUTE ON SA_LABEL_ADMIN TO ADMIN_BV;
-- Quyen gan policy cho cac table/schema
GRANT EXECUTE ON SA_POLICY_ADMIN TO ADMIN_BV;
--Quyen gan label cho tai khoan
GRANT EXECUTE ON SA_USER_ADMIN TO ADMIN_BV;
--Chuyen chuoi thanh so cua label
GRANT EXECUTE ON CHAR_TO_LABEL TO ADMIN_BV;

GRANT EXECUTE ON SA_AUDIT_ADMIN  TO ADMIN_BV;
GRANT LBAC_DBA TO ADMIN_BV;
GRANT EXECUTE ON SA_SYSDBA TO ADMIN_BV;
GRANT EXECUTE ON TO_LBAC_DATA_LABEL TO ADMIN_BV;

GRANT EXECUTE ON TO_LBAC_DATA_LABEL TO ADMIN_BV WITH GRANT OPTION;

-------================================================--------
--------B2: Dinh nghia cac thanh phan cua 1 label-------
-------================================================-------- 
---Do ADMIN_BV tao
CONNECT ADMIN_BV;
--- 3 level: DIRECTOR, MANAGER va EMPLOYEE
---Tao level
EXEC SA_COMPONENTS.CREATE_LEVEL('ACCESS_EMPLOYEES',3000,'DIR','DIRECTOR');
EXEC SA_COMPONENTS.CREATE_LEVEL('ACCESS_EMPLOYEES',2000,'MAN','MANAGER');
EXEC SA_COMPONENTS.CREATE_LEVEL('ACCESS_EMPLOYEES',1000,'EMP','EMPLOYEE');
--- 7 Compartment: (GOM CAC BO PHAN) HUMAN RESOURCE, SPECIALIZE, FINANCE, ACCOUNTING, DOCTOR, PHARMACIST, RECEPTIONIST 
---Tao compartment
EXEC SA_COMPONENTS.CREATE_COMPARTMENT('ACCESS_EMPLOYEES',7000, 'HUR','HUMAN_RESOURCE');
EXEC SA_COMPONENTS.CREATE_COMPARTMENT('ACCESS_EMPLOYEES',6000,'SPE','SPECIALIZE');
EXEC SA_COMPONENTS.CREATE_COMPARTMENT('ACCESS_EMPLOYEES',5000,'FIN','FINANCE');
EXEC SA_COMPONENTS.CREATE_COMPARTMENT('ACCESS_EMPLOYEES',4000,'ACC','ACCOUNTING');
EXEC SA_COMPONENTS.CREATE_COMPARTMENT('ACCESS_EMPLOYEES',3000,'PHA','PHARMACIST');
EXEC SA_COMPONENTS.CREATE_COMPARTMENT('ACCESS_EMPLOYEES',2000,'REC','RECEPTIONIST');
EXEC SA_COMPONENTS.CREATE_COMPARTMENT('ACCESS_EMPLOYEES',1000,'DOC','DOCTOR');
--- 3 group: (Toan benh vien va 2 chi nhanh) HOSPITAL, BRANCH01 va BRANCH02
---Tao group
EXECUTE SA_COMPONENTS.CREATE_GROUP('ACCESS_EMPLOYEES',30,'HOS','HOSPITAL');
EXECUTE SA_COMPONENTS.CREATE_GROUP('ACCESS_EMPLOYEES',20,'BRA1','BRANCH01','HOS');
EXECUTE SA_COMPONENTS.CREATE_GROUP('ACCESS_EMPLOYEES',10,'BRA2','BRANCH02','HOS');

-------========================================================--------
--------B3: Tao cac nhan du lieu that su-------
-------========================================================--------
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',30000,'DIR');

EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',27030,'MAN:HUR:HOS');

EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',27020,'MAN:HUR:BRA1');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',26020,'MAN:SPE:BRA1');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',25020,'MAN:FIN:BRA1');

EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',27010,'MAN:HUR:BRA2');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',26010,'MAN:SPE:BRA2');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',25010,'MAN:FIN:BRA2');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',24010,'MAN:ACC:BRA2');

EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',16020,'EMP:SPE:BRA1');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',15020,'EMP:FIN:BRA1');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',14020,'EMP:ACC:BRA1');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',13020,'EMP:PHA:BRA1');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',12020,'EMP:REC:BRA1');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',11020,'EMP:DOC:BRA1');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',10020,'EMP::BRA1');

EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',16010,'EMP:SPE:BRA2');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',15010,'EMP:FIN:BRA2');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',14010,'EMP:ACC:BRA2');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',13010,'EMP:PHA:BRA2');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',12010,'EMP:REC:BRA2');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',11010,'EMP:DOC:BRA2');
EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',10010,'EMP::BRA2');

EXECUTE SA_LABEL_ADMIN.CREATE_LABEL('ACCESS_EMPLOYEES',10000,'EMP');
-------===============================================================--------
--------B4: Gan chinh sach cho cac table hoac schema muon bao ve-------
-------================================================================--------
EXEC SA_POLICY_ADMIN.APPLY_TABLE_POLICY('ACCESS_EMPLOYEES','ADMIN_BV','EMPLOYEES','NO_CONTROL');

UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','DIR') WHERE EMP_TYPE = 0;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:HUR:HOS') WHERE EMP_ID = 'HR_MANAGER00';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:HUR:BRA1') WHERE EMP_TYPE = 1;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:FIN:BRA1') WHERE EMP_TYPE = 2;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:SPE:BRA1') WHERE EMP_TYPE = 3;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:REC:BRA1') WHERE EMP_TYPE = 4;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:ACC:BRA1') WHERE EMP_TYPE = 5;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:PHA:BRA1') WHERE EMP_TYPE = 6;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:DOC:BRA1') WHERE EMP_TYPE = 7;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:FIN:BRA1') WHERE EMP_TYPE = 8;

UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:HUR:BRA2') WHERE EMP_ID = 'HR_MANAGER03' OR EMP_ID = 'HR_MANAGER04';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:FIN:BRA2') WHERE EMP_ID = 'ACCOUNTING_MANAGER03' OR EMP_ID = 'ACCOUNTING_MANAGER04';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:SPE:BRA2') WHERE EMP_ID = 'SPECIALIZE_MANAGER03' OR EMP_ID = 'SPECIALIZE_MANAGER04';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:REC:BRA2') WHERE EMP_ID = 'RECEPTIONIST03' OR EMP_ID = 'RECEPTIONIST04';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:ACC:BRA2') WHERE EMP_ID = 'ACCOUNTING_STAFF03' OR EMP_ID = 'ACCOUNTING_STAFF04';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:PHA:BRA2') WHERE EMP_ID = 'PHARMACIST03' OR EMP_ID = 'PHARMACIST04';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:DOC:BRA2') WHERE EMP_ID = 'DOCTOR04' OR EMP_ID = 'DOCTOR05' OR EMP_ID = 'DOCTOR06';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:FIN:BRA2') WHERE EMP_ID = 'FINANCE_STAFF03' OR EMP_ID = 'FINANCE_STAFF04';

BEGIN
SA_POLICY_ADMIN.REMOVE_TABLE_POLICY
(POLICY_NAME => 'ACCESS_EMPLOYEES',
SCHEMA_NAME => 'ADMIN_BV',
TABLE_NAME => 'EMPLOYEES');
END;

BEGIN
SA_POLICY_ADMIN.APPLY_TABLE_POLICY
(POLICY_NAME =>'ACCESS_EMPLOYEES',
SCHEMA_NAME => 'ADMIN_BV',
TABLE_NAME => 'EMPLOYEES',
TABLE_OPTIONS =>'READ_CONTROL,WRITE_CONTROL,CHECK_CONTROL');
END;

-------=======================================================================--------
-------B5: Gan cac gioi han quyen, cac nhan nguoi dung---------------
-------hoac cac quyen truy xuat dac biet cho nhung nguoi dung lien quan-------------
-------========================================================================--------
---ADMIN_BV co toan quyen tren co so du lieu
BEGIN
SA_USER_ADMIN.SET_USER_PRIVS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'ADMIN_BV',
PRIVILEGES => 'FULL');
END;

---DIRECTOR benh vien co quyen doc tren toan bo co so du lieu
BEGIN
SA_USER_ADMIN.SET_USER_PRIVS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'DIRECTOR',
PRIVILEGES => 'READ');
END;

--HR_MANAGER00
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'HR_MANAGER00',
MAX_READ_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:HOS',
MAX_WRITE_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:HOS',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:HOS',
ROW_LABEL => 'MAN');
END;

--HR_MANAGER01
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'HR_MANAGER01',
MAX_READ_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA1',
MAX_WRITE_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA1',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA1',
ROW_LABEL => 'EMP::BRA1');
END;

---ACCOUNTING_MANAGER01
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'ACCOUNTING_MANAGER01',
MAX_READ_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA1',
MAX_WRITE_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA1',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA1',
ROW_LABEL => 'EMP:FIN:BRA1');
END;

---SPECIALIZE_MANAGER01
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'SPECIALIZE_MANAGER01',
MAX_READ_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA1',
MAX_WRITE_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA1',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA1',
ROW_LABEL => 'EMP:SPE:BRA1');
END;

---RECEPTIONIST01
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'RECEPTIONIST01',
MAX_READ_LABEL => 'EMP:REC:BRA1',
MAX_WRITE_LABEL => 'EMP:REC:BRA1',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'EMP:REC:BRA1',
ROW_LABEL => 'EMP:REC:BRA1');
END;

---FINANCE_STAFF01
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'FINANCE_STAFF01',
MAX_READ_LABEL => 'EMP:FIN:BRA1',
MAX_WRITE_LABEL => 'EMP:FIN:BRA1',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'EMP:FIN:BRA1',
ROW_LABEL => 'EMP:FIN:BRA1');
END;

---ACCOUNTING_STAFF01
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'ACCOUNTING_STAFF01',
MAX_READ_LABEL => 'EMP:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA1',
MAX_WRITE_LABEL => 'EMP:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA1',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'EMP:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA1',
ROW_LABEL => 'EMP::BRA1');
END;

---PHARMACIST01
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'PHARMACIST01',
MAX_READ_LABEL => 'EMP:PHA:BRA1',
MAX_WRITE_LABEL => 'EMP:PHA:BRA1',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'EMP:PHA:BRA1',
ROW_LABEL => 'EMP:PHA:BRA1');
END;

---DOCTOR01
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'DOCTOR01',
MAX_READ_LABEL => 'EMP:DOC:BRA1',
MAX_WRITE_LABEL => 'EMP:DOC:BRA1',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'EMP:DOC:BRA1',
ROW_LABEL => 'EMP:DOC:BRA1');
END;

--HR_MANAGER03
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'HR_MANAGER03',
MAX_READ_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA2',
MAX_WRITE_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA2',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA2',
ROW_LABEL => 'EMP::BRA2');
END;

---ACCOUNTING_MANAGER03
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'ACCOUNTING_MANAGER03',
MAX_READ_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA2',
MAX_WRITE_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA2',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA2',
ROW_LABEL => 'EMP:FIN:BRA2');
END;

---SPECIALIZE_MANAGER03
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'SPECIALIZE_MANAGER03',
MAX_READ_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA2',
MAX_WRITE_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA2',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'MAN:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA2',
ROW_LABEL => 'EMP:SPE:BRA2');
END;

---RECEPTIONIST03
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'RECEPTIONIST03',
MAX_READ_LABEL => 'EMP:REC:BRA2',
MAX_WRITE_LABEL => 'EMP:REC:BRA2',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'EMP:REC:BRA2',
ROW_LABEL => 'EMP:REC:BRA2');
END;

---FINANCE_STAFF03
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'FINANCE_STAFF03',
MAX_READ_LABEL => 'EMP:FIN:BRA2',
MAX_WRITE_LABEL => 'EMP:FIN:BRA2',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'EMP:FIN:BRA2',
ROW_LABEL => 'EMP:FIN:BRA2');
END;

---ACCOUNTING_STAFF03
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'ACCOUNTING_STAFF03',
MAX_READ_LABEL => 'EMP:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA2',
MAX_WRITE_LABEL => 'EMP:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA2',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'EMP:HUR,SPE,FIN,ACC,REC,DOC,PHA:BRA2',
ROW_LABEL => 'EMP::BRA2');
END;

---PHARMACIST03
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'PHARMACIST03',
MAX_READ_LABEL => 'EMP:PHA:BRA2',
MAX_WRITE_LABEL => 'EMP:PHA:BRA2',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'EMP:PHA:BRA2',
ROW_LABEL => 'EMP:PHA:BRA2');
END;

---DOCTOR04
BEGIN
SA_USER_ADMIN.SET_USER_LABELS
(POLICY_NAME =>'ACCESS_EMPLOYEES',
USER_NAME => 'DOCTOR04',
MAX_READ_LABEL => 'EMP:DOC:BRA2',
MAX_WRITE_LABEL => 'EMP:DOC:BRA2',
MIN_WRITE_LABEL => 'EMP',
DEF_LABEL => 'EMP:DOC:BRA2',
ROW_LABEL => 'EMP:DOC:BRA2');
END;

---Che giau cot thong tin chinh sach
BEGIN
SA_POLICY_ADMIN.REMOVE_TABLE_POLICY
(POLICY_NAME =>'ACCESS_EMPLOYEES',
SCHEMA_NAME => 'ADMIN_BV',
TABLE_NAME => 'EMPLOYEES',
DROP_COLUMN => TRUE);
END;

BEGIN
SA_POLICY_ADMIN.APPLY_TABLE_POLICY
(POLICY_NAME =>'ACCESS_EMPLOYEES',
SCHEMA_NAME => 'ADMIN_BV',
TABLE_NAME => 'EMPLOYEES',
TABLE_OPTIONS => 'NO_CONTROL');
END;

BEGIN
SA_POLICY_ADMIN.REMOVE_TABLE_POLICY
(POLICY_NAME =>'ACCESS_EMPLOYEES',
SCHEMA_NAME => 'ADMIN_BV',
TABLE_NAME => 'EMPLOYEES',
DROP_COLUMN => TRUE);
END;

BEGIN
SA_POLICY_ADMIN.APPLY_TABLE_POLICY
(POLICY_NAME =>'ACCESS_EMPLOYEES',
SCHEMA_NAME => 'ADMIN_BV',
TABLE_NAME => 'EMPLOYEES',
TABLE_OPTIONS => 'HIDE,NO_CONTROL');
END;

UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','DIR') WHERE EMP_TYPE = 0;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:HUR:HOS') WHERE EMP_ID = 'HR_MANAGER00';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:HUR:BRA1') WHERE EMP_TYPE = 1;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:FIN:BRA1') WHERE EMP_TYPE = 2;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:SPE:BRA1') WHERE EMP_TYPE = 3;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:REC:BRA1') WHERE EMP_TYPE = 4;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:ACC:BRA1') WHERE EMP_TYPE = 5;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:PHA:BRA1') WHERE EMP_TYPE = 6;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:DOC:BRA1') WHERE EMP_TYPE = 7;
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:FIN:BRA1') WHERE EMP_TYPE = 8;

UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:HUR:BRA2') WHERE EMP_ID = 'HR_MANAGER03' OR EMP_ID = 'HR_MANAGER04';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:FIN:BRA2') WHERE EMP_ID = 'ACCOUNTING_MANAGER03' OR EMP_ID = 'ACCOUNTING_MANAGER04';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','MAN:SPE:BRA2') WHERE EMP_ID = 'SPECIALIZE_MANAGER03' OR EMP_ID = 'SPECIALIZE_MANAGER04';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:REC:BRA2') WHERE EMP_ID = 'RECEPTIONIST03' OR EMP_ID = 'RECEPTIONIST04';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:ACC:BRA2') WHERE EMP_ID = 'ACCOUNTING_STAFF03' OR EMP_ID = 'ACCOUNTING_STAFF04';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:PHA:BRA2') WHERE EMP_ID = 'PHARMACIST03' OR EMP_ID = 'PHARMACIST04';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:DOC:BRA2') WHERE EMP_ID = 'DOCTOR04' OR EMP_ID = 'DOCTOR05' OR EMP_ID = 'DOCTOR06';
UPDATE EMPLOYEES SET OLS_EMPLOYEE = CHAR_TO_LABEL ('ACCESS_EMPLOYEES','EMP:FIN:BRA2') WHERE EMP_ID = 'FINANCE_STAFF03' OR EMP_ID = 'FINANCE_STAFF04';

BEGIN
SA_POLICY_ADMIN.REMOVE_TABLE_POLICY
(POLICY_NAME => 'ACCESS_EMPLOYEES',
SCHEMA_NAME => 'ADMIN_BV',
TABLE_NAME => 'EMPLOYEES');
END;

BEGIN
SA_POLICY_ADMIN.APPLY_TABLE_POLICY
(POLICY_NAME =>'ACCESS_EMPLOYEES',
SCHEMA_NAME => 'ADMIN_BV',
TABLE_NAME => 'EMPLOYEES',
TABLE_OPTIONS =>'HIDE,READ_CONTROL,WRITE_CONTROL,CHECK_CONTROL');
END;

---Ham gan nhan
CREATE OR REPLACE FUNCTION ADMIN_BV.GEN_EMP_LABEL
(Emp_Type INTEGER, BRANCH INTEGER)
RETURN LBACSYS.LBAC_LABEL
AS
I_LABEL VARCHAR2(100);
BEGIN
/************* XAC DINH LEVEL *************/
IF EMP_TYPE = 1 OR EMP_TYPE = 2 OR EMP_TYPE = 3 THEN
I_LABEL := 'MAN:';
ELSE
I_LABEL := 'EMP:';
END IF;
/************* XAC DINH COMPARTMENT *************/
IF EMP_TYPE = 4 THEN
I_LABEL := I_LABEL||'REC:';
ELSIF EMP_TYPE = 5 THEN
I_LABEL := I_LABEL||'ACC:';
ELSIF EMP_TYPE = 6 THEN
I_LABEL := I_LABEL||'PHA:';
ELSIF EMP_TYPE = 7 THEN
I_LABEL := I_LABEL||'DOC:';
ELSE
I_LABEL := I_LABEL||'FIN';
END IF;
/************* XAC DINH GROUPS *************/
IF BRANCH = 0 THEN
I_LABEL := I_LABEL||'HOS';
ELSIF BRANCH = 1 THEN
I_LABEL := I_LABEL||'BRA1';
ELSE
I_LABEL := I_LABEL||'BRA2';
END IF;
RETURN TO_LBAC_DATA_LABEL('ACCESS_EMPLOYEES',I_LABEL);
END;

GRANT EXECUTE ON ADMIN_BV.GEN_EMP_LABEL TO LBACSYS;

BEGIN
SA_POLICY_ADMIN.APPLY_TABLE_POLICY (
POLICY_NAME =>'ACCESS_EMPLOYEES',
SCHEMA_NAME => 'ADMIN_BV',
TABLE_NAME => 'EMPLOYEES',
TABLE_OPTIONS =>'HIDE,READ_CONTROL,WRITE_CONTROL,CHECK_CONTROL',
LABEL_FUNCTION =>'ADMIN_BV.GEN_EMP_LABEL(:NEW.EMP_TYPE,:NEW.BRANCH)');
END;

COMMIT;
=======
---Chinh sach bao mat voi MAC
---Giam doc benh vien, giam doc HR, truong phong HR, nhan vien HR
---Giam doc benh vien, giam doc tai chinh, truong phong tai chinh, nhan vien ke toan
---1)


---AUDIT
--STANDARD AUDIT
AUDIT INSERT, UPDATE, DELETE ON SYS.employees BY ACCESS;
AUDIT ALTER, DROP USER BY ACCESS;

--Audit VOI TRIGGER TREN BANG EMPLOYEES
DROP TABLE AUDIT_TABLE
CREATE TABLE AUDIT_TABLE (
  NEW_NAME VARCHAR2(50),
  OLD_NAME VARCHAR2(50),
  USER_NAME VARCHAR2(50),
  ENTRY_DATE VARCHAR2(50),
  OPERATION VARCHAR2(50)
);

CREATE OR REPLACE TRIGGER AD_EMPLOYEES_AUDIT
BEFORE INSERT OR UPDATE OR DELETE ON SYS.EMPLOYEES
FOR EACH ROW
ENABLE
DECLARE
  V_USER VARCHAR2(50);
  V_DATE VARCHAR2(50);
BEGIN
SELECT USER, TO_CHAR(SYSDATE, 'DD/MON/YYYY H24:MI:SS') INTO V_USER, V_DATE FROM DUAL;
IF INSERTING THEN
  INSERT INTO AUDIT_TABLE VALUES (:NEW.AUDIT_TABLE, NULL, V_USER, V_DATE, 'INSERT');
ELSE IF UPDATING THEN
  INSERT INTO AUDIT_TABLE VALUES (:NEW.AUDIT_TABLE, :OLD.AUDIT_TABLE, V_USER, V_DATE, 'UPDATE');
ELSE IF DELETING THEN
  INSERT INTO AUDIT_TABLE VALUES (NULL, :OLD.AUDIT_TABLE, V_USER, V_DATE, 'DELETE');
END IF;
END

--FINE-GRAINED AUDITING
--giam sat cac hoat dong insert, update, delete tren cac user cua ADMIN_BV
BEGIN
  sys.dbms_fga.add_policy(
    object_name => 'dba_users',
    policy_name => 'ADMIN_FGA',
    enable => true,
    statement_types => 'INSERT, UPDATE, DELETE',
    audit_trail => dbms_fga.db
    );
END;

-- MA HOA
-- xoa bang luu key
DROP TABLE NHOM22_K;
-- tao bang luu key
CREATE TABLE NHOM22_K
(
  NAME   VARCHAR2(100 BYTE),
  VALUE  NVARCHAR2(100)
);
 
INSERT INTO NHOM22_K
   SELECT 'key' NAME,
          RAWTOHEX ('52AB32;^$!ER94988OPS3W21') VALUE
     FROM DUAL
   UNION
   SELECT 'iv' NAME, RAWTOHEX ('TY54ABCX') VALUE FROM DUAL;
 
COMMIT;

-- ham ma hoa --
CREATE OR REPLACE FUNCTION F_ENCRYPT (p_input VARCHAR2)
   RETURN VARCHAR2
AS
   v_encrypted_raw     RAW (2000);
   v_key               RAW (320);
   v_encryption_type   PLS_INTEGER
      :=   DBMS_CRYPTO.DES_CBC_PKCS5;
   v_iv                RAW (320);
BEGIN
   SELECT VALUE
     INTO v_key
     FROM NHOM22_K
    WHERE name = 'key';
 
   SELECT VALUE
     INTO v_iv
     FROM NHOM22_K
    WHERE name = 'iv';
 
   v_encrypted_raw :=
      DBMS_CRYPTO.encrypt (src   => UTL_I18N.STRING_TO_RAW (p_input, 'AL32UTF8'),
                           typ   => v_encryption_type,
                           key   => v_key,
                           iv    => v_iv);
   RETURN UTL_RAW.CAST_TO_VARCHAR2 (UTL_ENCODE.base64_encode (v_encrypted_raw));
END;

-- ham giai ma --
CREATE OR REPLACE FUNCTION F_DECRYPT (p_input VARCHAR2)
   RETURN VARCHAR2
AS
   v_decrypted_raw     RAW (2000);
   v_key               RAW (320);
   v_encryption_type   PLS_INTEGER := DBMS_CRYPTO.DES_CBC_PKCS5;
   v_iv                RAW (320);
BEGIN
   SELECT VALUE
     INTO v_key
     FROM NHOM22_K
    WHERE name = 'key';
 
   SELECT VALUE
     INTO v_iv
     FROM NHOM22_K
    WHERE name = 'iv';
 
 
   v_decrypted_raw :=
      DBMS_CRYPTO.DECRYPT (
         src   => UTL_ENCODE.base64_decode (UTL_RAW.CAST_TO_RAW (p_input)),
         typ   => v_encryption_type,
         key   => v_key,
         iv    => v_iv);
 
 
   RETURN UTL_I18N.RAW_TO_CHAR (v_decrypted_raw, 'AL32UTF8');
END;

-- ma hoa cot ma BHYT trong bang Patients
UPDATE Patients SET HEALTH_INSURANCE_ID = F_ENCRYPT(HEALTH_INSURANCE_ID);

-- test ma hoa
select * from patients

SELECT '427862133' INPUT, 
        F_ENCRYPT('427862133') ENCRYPTED_RESULT,
        F_DECRYPT(F_ENCRYPT('427862133')) DECRYPT_RESULT 
FROM DUAL;
