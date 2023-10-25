/* Zadanie 1 */
SET SERVEROUTPUT ON;
DECLARE
    numer_max NUMBER(5);
BEGIN
   SELECT max(department_id) INTO numer_max FROM DEPARTMENTS;
   DBMS_OUTPUT.PUT_LINE('Zmienna numer_max: ' || numer_max);
   INSERT INTO departments(department_id, department_name) VALUES ((numer_max+10), 'EDUCATION');
EXCEPTION
   WHEN no_data_found THEN
        numer_max := 0;
END;

/* Zadanie 2 */
SET SERVEROUTPUT ON;
DECLARE
    numer_max NUMBER(5);
BEGIN
   SELECT max(department_id) INTO numer_max FROM DEPARTMENTS;
   DBMS_OUTPUT.PUT_LINE('Zmienna numer_max: ' || numer_max);
   INSERT INTO departments(department_id, department_name) VALUES ((numer_max+10), 'EDUCATION');
   UPDATE departments SET location_id = 3000 WHERE department_id = (numer_max+10);
EXCEPTION
   WHEN no_data_found THEN
        numer_max := 0;
END;

/* Zadanie 3 */
CREATE TABLE nowa (wartosc VARCHAR(10));
BEGIN
  FOR i IN 1..10 LOOP
    IF i != 4 AND i != 6 THEN
      INSERT INTO nowa (wartosc) VALUES (TO_CHAR(i));
    END IF;
  END LOOP;
  COMMIT;
END;

/* Zadanie 4 */
SET SERVEROUTPUT ON;
DECLARE
  pobrane_country COUNTRIES%ROWTYPE;
BEGIN
  SELECT * INTO pobrane_country FROM COUNTRIES WHERE COUNTRY_ID = 'CA';
  DBMS_OUTPUT.PUT_LINE('nazwa: ' || pobrane_country.COUNTRY_NAME);
  DBMS_OUTPUT.PUT_LINE('region_id: ' || pobrane_country.REGION_ID);
END;

/* Zadanie 5 */
SET SERVEROUTPUT ON;
DECLARE
    TYPE DepartmentIndex IS TABLE OF DEPARTMENTS.DEPARTMENT_NAME%TYPE INDEX BY BINARY_INTEGER;
    pobrane_departments DepartmentIndex;
BEGIN
    FOR i IN 1..10 LOOP
        pobrane_departments(i * 10) := NULL;
        SELECT DEPARTMENT_NAME INTO pobrane_departments(i * 10)
        FROM DEPARTMENTS
        WHERE DEPARTMENT_ID = i * 10;
    END LOOP;
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE('Numer departamentu: ' || i * 10);
		DBMS_OUTPUT.PUT_LINE('Nazwa departamentu: ' || pobrane_departments(i * 10));
		DBMS_OUTPUT.PUT_LINE('--------------------------------');
    END LOOP;
END;

/* Zadanie 6 */
SET SERVEROUTPUT ON;
DECLARE
  pobrane_department DEPARTMENTS%ROWTYPE;
BEGIN
  FOR i IN 1..10 LOOP
    SELECT * INTO pobrane_department
    FROM DEPARTMENTS
    WHERE DEPARTMENT_ID = i * 10;
    DBMS_OUTPUT.PUT_LINE('ID: ' || pobrane_department.department_id);
    DBMS_OUTPUT.PUT_LINE('Nazwa departamentu: ' || pobrane_department.department_name);
    DBMS_OUTPUT.PUT_LINE('ID menedzera: ' || pobrane_department.manager_id);
    DBMS_OUTPUT.PUT_LINE('ID lokalizacji: ' || pobrane_department.location_id);
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
  END LOOP;
END;

/* Zadanie 7 */
SET SERVEROUTPUT ON;
DECLARE
    CURSOR c_employees IS SELECT LAST_NAME, SALARY FROM EMPLOYEES WHERE DEPARTMENT_ID = 50;
    pobrane_last_name employees.last_name%TYPE;
    pobrane_salary employees.salary%TYPE;
BEGIN
    FOR emp_rec IN c_employees LOOP
        pobrane_last_name := emp_rec.last_name;
        pobrane_salary := emp_rec.salary;
        IF pobrane_salary > 3100 THEN
            DBMS_OUTPUT.PUT_LINE(pobrane_last_name || ' nie dawac podwyzki');
        ELSE
            DBMS_OUTPUT.PUT_LINE(pobrane_last_name || ' dac podwyzke');
        END IF;
    END LOOP;
END;

/* Zadanie 8 */
SET SERVEROUTPUT ON;
DECLARE
    CURSOR c_employee_salary (MIN_SALARY NUMBER, MAX_SALARY NUMBER, NAME_PART VARCHAR)
    IS SELECT FIRST_NAME, LAST_NAME, SALARY FROM EMPLOYEES WHERE SALARY BETWEEN MIN_SALARY AND MAX_SALARY AND UPPER(FIRST_NAME) LIKE '%' || UPPER(NAME_PART) || '%';
  
    pobrane_first_name EMPLOYEES.FIRST_NAME%TYPE;
    pobrane_last_name EMPLOYEES.LAST_NAME%TYPE;
    pobrane_salary EMPLOYEES.SALARY%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Pracownicy z zarobkami 1000-5000 i imieniem zawierajacym "a" lub "A":');
    DBMS_OUTPUT.PUT_LINE('_____________________________________________________________________');
    FOR e1 IN c_employee_salary(1000, 5000, 'a') LOOP
        pobrane_first_name := e1.first_name;
        pobrane_last_name := e1.last_name;
        pobrane_salary := e1.salary;
        DBMS_OUTPUT.PUT_LINE(pobrane_first_name || ' ' || pobrane_last_name || ' - Zarobki: ' || pobrane_salary);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Pracownicy z zarobkami 5000-20000 i imieniem zawierajacym "u" lub "U":');
    DBMS_OUTPUT.PUT_LINE('_____________________________________________________________________');
    FOR e2 IN c_employee_salary(5000, 20000, 'u') LOOP
        pobrane_first_name := e2.first_name;
        pobrane_last_name := e2.last_name;
        pobrane_salary := e2.salary;
        DBMS_OUTPUT.PUT_LINE(pobrane_first_name || ' ' || pobrane_last_name || ' - Zarobki: ' || pobrane_salary);
    END LOOP;
END;

/* Zadanie 9 */
/* a. */
CREATE OR REPLACE PROCEDURE DodajJob(
  v_Job_id Jobs.Job_id%TYPE,
  v_Job_title Jobs.Job_title%TYPE
)
AS
BEGIN
  INSERT INTO Jobs (Job_id, Job_title)
  VALUES (v_Job_id, v_Job_title);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('SQLERROR: ' || SQLERRM);
END DodajJob;


CALL DodajJob('AD_TECH', 'Administration Technics');
CALL DodajJob('ST_TECH', 'Stock Technics');

/* b. */
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE EdytujJob(
    v_JOB_id JOBS.job_id%TYPE,
    v_JOB_title JOBS.job_title%TYPE
)
AS
    NO_JOBS_UPDATED EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_JOBS_UPDATED, -20000);
BEGIN
    UPDATE JOBS SET JOB_TITLE = v_JOB_TITLE WHERE JOB_ID = V_JOB_ID;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE NO_JOBS_UPDATED;
    END IF;
    COMMIT;
EXCEPTION
    WHEN NO_JOBS_UPDATED THEN
        DBMS_OUTPUT.PUT_LINE('Brak aktualizacji w tabeli Jobs.');
END EdytujJob;

CALL EdytujJob('AD_TECH','Administration Tech');
CALL EdytujJob('ST_TECH', 'Stock Techn');

/* c. */
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE UsunJob(
    v_job_id JOBS.JOB_ID%TYPE
)
AS
    NO_JOBS_DELETED EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_JOBS_DELETED, -20001);
BEGIN
    DELETE FROM JOBS WHERE JOB_ID = v_job_id;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE NO_JOBS_DELETED;
    END IF;
    COMMIT;
EXCEPTION
    WHEN NO_JOBS_DELETED THEN
        DBMS_OUTPUT.PUT_LINE('Nie usunieto nic w tabeli Jobs.');
END UsunJob;

CALL UsunJob('ST_TECH');
CALL UsunJob('ST_TECH');

/* d. */
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE ZarobkiPracownika(
    v_employee_id EMPLOYEES.EMPLOYEE_ID%TYPE,
    pobrane_zarobki OUT EMPLOYEES.SALARY%TYPE,
    pobrane_nazwisko OUT EMPLOYEES.LAST_NAME%TYPE
)
AS
BEGIN
    SELECT SALARY, LAST_NAME INTO pobrane_zarobki, pobrane_nazwisko FROM EMPLOYEES
    WHERE EMPLOYEES.EMPLOYEE_ID = V_EMPLOYEE_ID;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak pracownika o podanym ID.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SQLERROR: ' || SQLERRM);
END ZarobkiPracownika;


SET SERVEROUTPUT ON;
DECLARE
  x_zarobki NUMBER;
  x_nazwisko VARCHAR(255);
BEGIN
    ZarobkiPracownika(123, x_zarobki, x_nazwisko);
    IF x_zarobki IS NOT NULL THEN
	    DBMS_OUTPUT.PUT_LINE('Nazwisko pracownika: ' || x_nazwisko);
        DBMS_OUTPUT.PUT_LINE('Zarobki pracownika: ' || x_zarobki);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Brak pracownika o podanym ID lub error: ' || x_nazwisko);
    END IF;
END;


DECLARE
  x_zarobki NUMBER;
  x_nazwisko VARCHAR(255);
BEGIN
    ZarobkiPracownika(210, x_zarobki, x_nazwisko);
    IF x_zarobki IS NOT NULL THEN
	    DBMS_OUTPUT.PUT_LINE('Nazwisko pracownika: ' || x_nazwisko);
        DBMS_OUTPUT.PUT_LINE('Zarobki pracownika: ' || x_zarobki);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Brak pracownika o podanym ID lub error: ' || x_nazwisko);
    END IF;
END;
3
/* e. */
SET SERVEROUTPUT ON;
CREATE PROCEDURE DodajPracownik(
    x_first_name EMPLOYEES.FIRST_NAME%TYPE,
    x_last_name EMPLOYEES.LAST_NAME%TYPE,
    x_salary EMPLOYEES.SALARY%TYPE DEFAULT 1000,
	x_email EMPLOYEES.EMAIL%TYPE DEFAULT 'zmiento@emajl.pl',   
    x_phone_number EMPLOYEES.PHONE_NUMBER%TYPE DEFAULT '000.000.000',
    x_hire_date EMPLOYEES.HIRE_DATE%TYPE DEFAULT SYSDATE,
    x_job_id EMPLOYEES.JOB_ID%TYPE DEFAULT 'AD_TECH',
    x_commission_pct EMPLOYEES.COMMISSION_PCT%TYPE DEFAULT NULL,
    x_manager_id EMPLOYEES.MANAGER_ID%TYPE DEFAULT NULL,
    x_department_id EMPLOYEES.DEPARTMENT_ID%TYPE DEFAULT 60
)
AS
    wynagrodzenie_za_wysokie EXCEPTION;
    PRAGMA EXCEPTION_INIT(wynagrodzenie_za_wysokie, -20002);
BEGIN
    IF x_salary > 20000 THEN
        RAISE wynagrodzenie_za_wysokie;
    ELSE
        INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID)
        VALUES ((select max(EMPLOYEE_ID) from EMPLOYEES ) + 1, x_first_name, x_last_name, x_email, x_phone_number, x_hire_date, x_job_id, x_salary, x_commission_pct, x_manager_id, x_department_id);
        COMMIT;
    END IF;
EXCEPTION
    WHEN wynagrodzenie_za_wysokie THEN
        DBMS_OUTPUT.PUT_LINE('Wynagrodzenie za wysokie >20000, nie mozna dodac pracownika.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SQLERROR: ' || SQLERRM);
END DodajPracownik;

CALL DodajPracownik('Ala', 'Ma', 1000);
CALL DodajPracownik('Maciej', 'Kota', 20001);
CALL DodajPracownik('Robert', 'Bar', 2000, 'rabarbar@gmail.com');