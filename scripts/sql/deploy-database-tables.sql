/*  File to create tables and load sample data  */

/* VENDORS */

-- Vendors table
CREATE TABLE IF NOT EXISTS vendors (
    id BIGSERIAL PRIMARY KEY,
    name text NOT NULL,
    address text NOT NULL,
    contact_name text NOT NULL,
    contact_email text NOT NULL,
    contact_phone text NOT NULL,
    website text NOT NULL,
    type text NOT NULL
);

-- Insert vendors only if vendors table is empty
INSERT INTO vendors (id, name, address, contact_name, contact_email, contact_phone, website, type)
SELECT v.id, v.name, v.address, v.contact_name, v.contact_email, v.contact_phone, v.website, v.type
FROM (
    SELECT 1 as id, 'Adatum Corporation' as name, '789 Goldsmith Road, MainTown City' as address, 'Elizabeth Moore' as contact_name, 'elizabeth.moore@adatum.com' as contact_email, '555-789-7890' as contact_phone, 'http://www.adatum.com' as website, 'Data Engineering' as type
    UNION ALL
    SELECT 2, 'Trey Research', '456 Research Avenue, Redmond', 'Serena Davis', 'serena.davis@treyresearch.net', '555-867-5309', 'http://www.treyresearch.net', 'DevOps'
    UNION ALL
    SELECT 3, 'Lucerne Publishing', '789 Live Street, Woodgrove', 'Ana Bowman', 'abowman@lucernepublishing.com', '555-654-9870', 'http://www.lucernepublishing.com', 'Graphic Design'
    UNION ALL
    SELECT 4, 'VanArsdel, Ltd.', '123 Innovation Drive, TechVille', 'Gabriel Diaz', 'gdiaz@vanarsdelltd.com', '555-321-0987', 'http://www.vanarsdelltd.com', 'Software Engineering'
    UNION ALL
    SELECT 5, 'Contoso, Ltd.', '456 Industrial Road, Scooton City', 'Nicole Wagner', 'nicole@contoso.com', '555-654-3210', 'http://www.contoso.com', 'Software Engineering'
    UNION ALL
    SELECT 6, 'Fabrikam, Inc.', '24601 South St., Philadelphia', 'Remy Morris', 'remy.morris@fabrikam.com', '610-321-0987', 'http://www.fabrikam.com', 'AI Services'
    UNION ALL
    SELECT 7, 'The Phone Company', '10642 Meridian St., Indianapolis', 'Ashley Schroeder', 'ashley.schroeder@thephone-company.com', '719-444-2345', 'http://www.thephone-company.com', 'Communications'
) as v
WHERE NOT EXISTS (SELECT 1 FROM vendors);

CREATE SEQUENCE IF NOT EXISTS vendors_id_seq;
SELECT setval('vendors_id_seq', COALESCE((SELECT MAX(id) FROM vendors), 1) + 1);
ALTER TABLE vendors ALTER COLUMN id SET DEFAULT nextval('vendors_id_seq');

/* END VENDORS */

/* STATUS */

-- Status table
DROP TABLE IF EXISTS status;
CREATE TABLE IF NOT EXISTS status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

-- Insert status values
INSERT INTO status (id, name, description) VALUES (1, 'Pending', 'Awaiting action');
INSERT INTO status (id, name, description) VALUES (2, 'In Progress', 'In progress');
INSERT INTO status (id, name, description) VALUES (3, 'In Review', 'Review is required');
INSERT INTO status (id, name, description) VALUES (4, 'Cancelled', 'The process was stopped');
INSERT INTO status (id, name, description) VALUES (5, 'Overdue', 'The invoice has passed the due date without payment');
INSERT INTO status (id, name, description) VALUES (6, 'Paid', 'The invoice has been fully paid');
INSERT INTO status (id, name, description) VALUES (7, 'Completed', 'Work has been finished');

CREATE SEQUENCE IF NOT EXISTS status_id_seq;
SELECT setval('status_id_seq', COALESCE((SELECT MAX(id) FROM status), 1) + 1);
ALTER TABLE status ALTER COLUMN id SET DEFAULT nextval('status_id_seq');

/* END STATUS */

/* SOWs */

-- Statement of work table
CREATE TABLE IF NOT EXISTS sows (
    id BIGSERIAL PRIMARY KEY,
    number text NOT NULL,
    vendor_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(18,2) NOT NULL,
    document text NOT NULL,
    metadata JSONB, --  additional metadata
    summary text,
    FOREIGN KEY (vendor_id) REFERENCES vendors (id) ON DELETE CASCADE
);

-- Insert sow values only if the specific sow number does not exist
INSERT INTO sows (number, vendor_id, start_date, end_date, budget, document, metadata)
SELECT 'SOW-2024-073',
       1,
       '2024-11-01',
       '2025-12-31',
       43600.00,
       '1/sow/Statement_of_Work_Adatum_Corporation_Woodgrove_Bank_20241101.pdf',
       '{}'
WHERE NOT EXISTS (SELECT 1 FROM sows WHERE number = 'SOW-2024-073');

INSERT INTO sows (number, vendor_id, start_date, end_date, budget, document, metadata)
SELECT 'SOW-2024-038',
       2,
       '2024-05-01',
       '2025-08-31',
       60000.00,
       '2/sow/Statement_of_Work_Trey_Research_Woodgrove_Bank_20240501.pdf',
       '{}'
WHERE NOT EXISTS (SELECT 1 FROM sows WHERE number = 'SOW-2024-038');

INSERT INTO sows (number, vendor_id, start_date, end_date, budget, document, metadata)
SELECT 'SOW-2024-081',
       3,
       '2024-12-01',
       '2024-12-31',
       33000.00,
       '3/sow/Statement_of_Work_Lucerne_Publishing_Woodgrove_Bank_20241201.pdf',
       '{}'
WHERE NOT EXISTS (SELECT 1 FROM sows WHERE number = 'SOW-2024-081');

INSERT INTO sows (number, vendor_id, start_date, end_date, budget, document, metadata)
SELECT 'SOW-2024-070',
       4,
       '2024-10-01',
       '2025-09-30',
       55000.00,
       '4/sow/Statement_of_Work_VanArsdel_Ltd_Woodgrove_Bank_20241001.pdf',
       '{}'
WHERE NOT EXISTS (SELECT 1 FROM sows WHERE number = 'SOW-2024-070');

INSERT INTO sows (number, vendor_id, start_date, end_date, budget, document, metadata)
SELECT 'SOW-2024-052',
       5,
       '2024-06-01',
       '2025-11-30',
       115000.00,
       '5/sow/Statement_of_Work_Contoso_Ltd_Woodgrove_Bank_20240601.pdf',
       '{}'
WHERE NOT EXISTS (SELECT 1 FROM sows WHERE number = 'SOW-2024-052');

-- SOW Chunks table: Holds the content of the SOW in sections
CREATE TABLE IF NOT EXISTS sow_chunks (
    id BIGSERIAL PRIMARY KEY,
    sow_id BIGINT NOT NULL,
    heading text NOT NULL,
    content text NOT NULL,
    page_number INT NOT NULL,
    FOREIGN KEY (sow_id) REFERENCES sows (id) ON DELETE CASCADE
);

-- Insert starter data for sow_chunks
INSERT INTO sow_chunks (sow_id, heading, content, page_number)
VALUES
(1, 'Project Scope', 'Adatum Corporation will provide comprehensive Azure resource management services, including infrastructure monitoring, automated scaling, cost optimization, and application troubleshooting, to ensure high availability and efficiency for Woodgrove Bank.', 1),
(1, 'Project Objectives', 'Ensure the continuous performance and scalability of Azure resources. Implement cost-efficient resource management strategies. Minimize downtime through proactive monitoring and rapid troubleshooting.', 1),
(1, 'Tasks', '1. Set up Azure resource monitoring tools. 2. Design and implement automated scaling strategies. 3. Conduct cost analysis and apply optimization measures. 4. Perform regular maintenance on Azure-hosted applications. 5. Troubleshoot and resolve any application or resource issues.', 1),
(1, 'Schedules', 'Project kick-off: November 01, 2024 - Initial monitoring setup: November 08, 2024 - Scaling implementation: November 15, 2024 - Cost optimization review: November 22, 2024 - Maintenance practices established: December 13, 2024 - Final troubleshooting and wrap-up: December 31, 2025', 1),
(1, 'Payments', 'Payment terms are Net 30. Invoices will be issued upon the completion of each milestone and are payable within 30 days. A penalty of 10% will be applied for late deliveries or payments.', 1),
(1, 'Compliance', '- Data Security: All data transfers between the Service Provider and Client will use secure, encrypted communication protocols. Data at rest will be encrypted using industry-standard encryption algorithms (e.g., AES-256). - Access Control: Access to the Azure resources and sensitive client information will be granted only to authorized personnel. Multi-factor authentication (MFA) will be enforced for all administrative access. - Audit and Monitoring: Adatum Corporation will maintain comprehensive logs of all access and changes to Azure resources. Regular audits will be conducted to ensure compliance with security protocols. - Incident Response: In the event of a security incident, the Service Provider will notify the Client within 24 hours. A detailed incident report will be provided within 48 hours, outlining the root cause, impact, and mitigation steps. - Regulatory Compliance: The project will comply with applicable regulations, including GDPR, PCI DSS, and ISO 27001, as they pertain to the management of Azure resources.', 2),
(1, 'Project Deliverables', 'Milestone Name Deliverables Amount Due Date 1 Monitoring Monitoring of resources $8,600.00 2024-11-08 2 Resource Scaling Implementation of automated scaling $7,000.00 2024-11-15 3 Cost Management Cost Management Implementation $7,000.00 2024-11-22 4 Maintenance Practices Maintenance & troubleshooting practice $10,500.00 2024-11-27 5 App Troubleshooting Identify Azure application issues $2,000.00 2024-11-27 5 App Troubleshooting Resolution of Azure application issues $3,500.00 2024-12-13 5 App Troubleshooting Implementation of app monitoring $5,000.00 2024-12-31 Total $43,600.00 Signatures (Adatum Corporation - Elizabeth Moore) (Woodgrove Bank - Sora Kim)', 2);

CREATE SEQUENCE IF NOT EXISTS sow_chunks_id_seq;
SELECT setval('sow_chunks_id_seq', COALESCE((SELECT MAX(id) FROM sow_chunks), 1) + 1);
ALTER TABLE sow_chunks ALTER COLUMN id SET DEFAULT nextval('sow_chunks_id_seq');

-- Milestones table: Holds the milestones for each SOW
CREATE TABLE IF NOT EXISTS milestones (
    id BIGSERIAL PRIMARY KEY,
    sow_id BIGINT NOT NULL,
    name text NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (sow_id) REFERENCES sows (id) ON DELETE CASCADE
);

-- Insert starter data for milestones 
INSERT INTO milestones (sow_id, name, status)
VALUES
    (1,'Monitoring','Completed'),
    (1,'Resource Scaling','Completed'),
    (1,'Cost Management','Completed'),
    (1,'Maintenance Practices','Completed'),
    (1,'App Troubleshooting','In Progress'),
    (2,'DevOps Strategy & Planning','Completed'),
    (2,'CI/CD Pipeline Implementation','Completed'),
    (2,'Infrastructure as Code (IaC)','Completed'),
    (2,'Security, Monitoring & Optimization', 'In Progress');

CREATE SEQUENCE IF NOT EXISTS milestones_id_seq;
SELECT setval('milestones_id_seq', COALESCE((SELECT MAX(id) FROM milestones), 1) + 1);
ALTER TABLE milestones ALTER COLUMN id SET DEFAULT nextval('milestones_id_seq');

-- Deliverables table: Holds the deliverables for each milestone
CREATE TABLE IF NOT EXISTS deliverables (
    id BIGSERIAL PRIMARY KEY,
    milestone_id BIGINT NOT NULL,
    description TEXT,
    amount NUMERIC(10, 2),
    status TEXT NOT NULL,
    due_date DATE NOT NULL,
    FOREIGN KEY (milestone_id) REFERENCES milestones (id) ON DELETE CASCADE
);

-- Insert starter data for deliverables
INSERT INTO deliverables (milestone_id, description, amount, status, due_date)
VALUES
(1,'Monitoring of resources',8600.00,'Completed', '2024-11-08'),
(2,'Implementation of automated scaling',7000.00,'Completed', '2024-11-08'),
(3,'Cost Management Implementation',7000.00,'Completed', '2024-11-22'),
(4,'Maintenance and troubleshooting practices',10500.00,'Completed', '2024-11-27'),
(5,'Identify Azure application issues',2000.00,'In Progress', '2024-11-27'),
(5,'Resolution of Azure application issues',3500.00,'Completed', '2024-12-13'),
(5,'Implementation of app monitoring',5000.00,'In Progress', '2024-12-31'),
(6,'DevOps Roadmap & Report',10000.00,'Completed','2024-11-20');

CREATE SEQUENCE IF NOT EXISTS deliverables_id_seq;
SELECT setval('deliverables_id_seq', COALESCE((SELECT MAX(id) FROM deliverables), 1) + 1);
ALTER TABLE deliverables ALTER COLUMN id SET DEFAULT nextval('deliverables_id_seq');

-- SOW Validation Results table
CREATE TABLE IF NOT EXISTS sow_validation_results (
    id BIGSERIAL PRIMARY KEY,
    sow_id BIGINT NOT NULL,
    datestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    result TEXT,
    validation_passed BOOLEAN,
    FOREIGN KEY (sow_id) REFERENCES sows (id) ON DELETE CASCADE
);

-- Insert starter data for sow_validation_results
INSERT INTO sow_validation_results (
    sow_id,
    datestamp,
    result,
    validation_passed
)
VALUES
    (1, CURRENT_TIMESTAMP - INTERVAL '2 hours', 'Missing deliverables section.', FALSE),
    (1, CURRENT_TIMESTAMP - INTERVAL '1 hour', 'Deliverables section contains wrong information and incorrect total billable amount for milestone 1.', FALSE),
    (1, CURRENT_TIMESTAMP, 'The SOW has been correct and is now correct.', TRUE),
    (2, CURRENT_TIMESTAMP - INTERVAL '1 hour', 'Incorrect milestone dates.', FALSE),
    (2, CURRENT_TIMESTAMP, 'Everything is correct now.', TRUE),
    (3, CURRENT_TIMESTAMP, 'SOW looks good.', TRUE),
    (4, CURRENT_TIMESTAMP, 'The required compliance section is missing.', FALSE),
    (4, CURRENT_TIMESTAMP, 'All fields are valid.', TRUE),
    (5, CURRENT_TIMESTAMP, 'All fields are valid.', TRUE);

CREATE SEQUENCE IF NOT EXISTS sow_validation_results_id_seq;
SELECT setval('sow_validation_results_id_seq', COALESCE((SELECT MAX(id) FROM sow_validation_results), 1) + 1);
ALTER TABLE sow_validation_results ALTER COLUMN id SET DEFAULT nextval('sow_validation_results_id_seq');

/* END SOWs */

/* INVOICES */

-- Invoices table
CREATE TABLE IF NOT EXISTS invoices (
    id BIGSERIAL PRIMARY KEY,
    number text NOT NULL,
    vendor_id BIGINT NOT NULL,
    sow_id BIGINT NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    invoice_date DATE NOT NULL,
    payment_status VARCHAR(50) NOT NULL,
    document text NOT NULL, -- document path
    content text, --  text content from the invoice
    metadata JSONB, --  additional metadata
    FOREIGN KEY (vendor_id) REFERENCES vendors (id) ON DELETE CASCADE,
    FOREIGN KEY (sow_id) REFERENCES sows (id) ON DELETE CASCADE
);

-- Insert starter data for invoices
INSERT INTO invoices (id, number, vendor_id, sow_id, amount, invoice_date, payment_status, document, content, metadata)
VALUES
    (1, 'INV-AC2024-001', 1, 1, 15600, '2024-12-08', 'Paid', '1/invoice/INV-AC2024-001.pdf',  '{"Invoice Number: INV-AC2024-001 Vendor: Adatum Corporation Address: 789 Goldsmith Road, MainTown City Contact Name: Elizabeth Moore Contact Email: elizabeth.moore@adatum.com Contact Number: 123-789-7890 SOW Number: SOW-2024-073 Invoice Date: 2024-11-08 Client: Woodgrove Bank Address: 123 Financial Avenue, Woodgrove City Milestone  Deliverables Amount Due Date Monitoring Monitoring of resources $8600.00 2024-12-08 Cost Management Cost Mangement Implementation $7000.00 2024-12-08 Total Amount $15600.00 If paying by Direct Credit please pay into the following bank account: Account Name: Adatum Corporation Account Number: 99182326 To help us allocate money correctly, please reference your invoice number: INV-AC2024-001 Payment Terms - Payment is due within 30 days of the invoice date. - A penalty of 10% will be applied for late payments."}', '{}'),
    (2, 'INV-AC2024-002', 1, 1, 7000, '2024-12-22', 'Paid', '2/invoice/INV-AC2024-002.pdf', '{"Invoice Number: INV-AC2024-002 Vendor: Adatum Corporation Address: 789 Goldsmith Road, MainTown City Contact Name: Elizabeth Moore Contact Email: elizabeth.moore@adatum.com Contact Number: 123-789-7890 SOW Number: SOW-2024-073 Invoice Date: 2024-11-22 Client: Woodgrove Bank Address: 123 Financial Avenue, Woodgrove City Milestone Deliverables Amount Due Date Resource Scaling Implementation of automated scaling $7000.00 2024-12-22 Total Amount $7000.00 If paying by Direct Credit please pay into the following bank account: Account Name: Adatum Corporation Account Number: 99182326 To help us allocate money correctly, please reference your invoice number: INV-AC2024-002 Payment Terms - Payment is due within 30 days of the invoice date. - A penalty of 10% will be applied for late payments."}', '{}'),
    (3, 'INV-AC2024-003', 1, 1, 12500, '2024-12-27', 'In Review', '3/invoice/INV-AC2024-003.pdf',  '{"Invoice Number: INV-AC2024-003 Vendor: Adatum Corporation Address: 789 Goldsmith Road, MainTown City Contact Name: Elizabeth Moore Contact Email: elizabeth.moore@adatum.com Contact Number: 123-789-7890 SOW Number: SOW-2024-073 Invoice Date: 2024-11-27 Client: Woodgrove Bank Address: 123 Financial Avenue, Woodgrove City Milestone Deliverables Amount Due Date Maintenance Practices Maintenance and troubleshooting practices $10500.00 2024-12-27 App Troubleshooting Identify Azure application issues $2000.00 2024-12-27 Total Amount $12500.00 If paying by Direct Credit please pay into the following bank account: Account Name: Adatum Corporation Account Number: 99182326 To help us allocate money correctly, please reference your invoice number: INV-AC2024-003 Payment Terms - Payment is due within 30 days of the invoice date. - A penalty of 10% will be applied for late payments."}', '{}'),
    (4, 'INV-AC2024-004', 1, 1, 8500, '2024-01-31', 'Pending', '4/invoice/INV-AC2024-004.pdf',  '{"Invoice Number: INV-AC2024-004 Vendor: Adatum Corporation Address: 789 Goldsmith Road, MainTown City Contact Name: Elizabeth Moore Contact Email: elizabeth.moore@adatum.com Contact Number: 123-789-7890 SOW Number: SOW-2024-073 Invoice Date: 2024-12-01 Client: Woodgrove Bank Address: 123 Financial Avenue, Woodgrove City Milestone Deliverables Amount Due Date App Troubleshooting Resolution of Azure application issues $3500.00 2024-12-31 App Troubleshooting Implementation of app monitoring 5,000.00 2024-12-31 Total Amount $8500.00 If paying by Direct Credit please pay into the following bank account: Account Name: Adatum Corporation Account Number: 99182326 To help us allocate money correctly, please reference your invoice number: INV-AC2024-004 Payment Terms - Payment is due within 30 days of the invoice date. - A penalty of 10% will be applied for late payments."}', '{}'),
    (5, 'INV-TR2024-001', 2, 2, 10000, '2024-11-20', 'Paid', '5/invoice/INV-TR2024-001.pdf',  '{"Invoice Number: INV-TR2024-001 Vendor: Trey Research Address: 456 Research Avenue, Redmond Contact Name: Serena Davis Contact Email: serena.davis@treyresearch.net Contact Number: 555-867-5309 SOW Number: SOW-2024-038 Invoice Date: 2024-11-20 Client: Woodgrove Bank Address: 123 Financial Avenue, Woodgrove City Milestone Deliverables Amount Due Date DevOps Strategy DevOps Roadmap & Report $10000.00 2024-12-20 Total Amount $10000.00 If paying by Direct Credit please pay into the following bank account: Account Name: Trey Research Account Number: 41536685 To help us allocate money correctly, please reference your invoice number: INV-TR2024-001 Payment Terms - Payment is due within 30 days of the invoice date. - A penalty of 10% will be applied for late payments."}', '{}');

CREATE SEQUENCE IF NOT EXISTS invoices_id_seq;
SELECT setval('invoices_id_seq', COALESCE((SELECT MAX(id) FROM invoices), 1) + 1);
ALTER TABLE invoices ALTER COLUMN id SET DEFAULT nextval('invoices_id_seq');

-- Invoice Line Items table
CREATE TABLE IF NOT EXISTS invoice_line_items (
    id BIGSERIAL PRIMARY KEY,
    invoice_id BIGINT NOT NULL,
    description TEXT,
    amount NUMERIC(10, 2),
    status TEXT NOT NULL,
    due_date DATE NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
);

-- Insert starter data for invoice_line_items
INSERT INTO invoice_line_items (invoice_id, description, amount, status, due_date)
VALUES

(1,'Monitoring of resources',8600,'Completed','2024-12-08'),
(1,'Cost Management Implementation',7000,'Completed','2024-12-08'),
(2,'Implementation of automated scaling',7000,'Completed','2024-12-22'),
(3,'Maintenance and troubleshooting practices',10500,'Completed','2024-12-27'),
(3,'Identify Azure application issues',2000,'In Progress','2024-12-27'),
(4,'Resolution of Azure application issues',3500,'Completed','2025-01-31'),
(4,'Implementation of app monitoring',5000,'In Progress','2025-01-31'),
(5,'DevOps Roadmap & Report',10000,'Completed','2024-12-20');

CREATE SEQUENCE IF NOT EXISTS invoice_line_items_id_seq;
SELECT setval('invoice_line_items_id_seq', COALESCE((SELECT MAX(id) FROM invoice_line_items), 1) + 1);
ALTER TABLE invoice_line_items ALTER COLUMN id SET DEFAULT nextval('invoice_line_items_id_seq');

-- Invoice Validation Results table
CREATE TABLE IF NOT EXISTS invoice_validation_results (
    id BIGSERIAL PRIMARY KEY,
    invoice_id BIGINT NOT NULL,
    datestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    result TEXT,
    validation_passed BOOLEAN,
    FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
);

-- Insert starter data for invoice_validation_results
INSERT INTO invoice_validation_results (
    invoice_id, 
	datestamp,
    result, 
    validation_passed
)
VALUES
    
    (1, CURRENT_TIMESTAMP - INTERVAL '2 hours', 'Total amount was wrong.', FALSE),
    (1, CURRENT_TIMESTAMP, 'Invoice had total amount added changed and passed with no errors.', TRUE),
    (2, CURRENT_TIMESTAMP, 'Invoice validation passed with warnings: Payment terms was missing penalty text.', TRUE),
    (3, CURRENT_TIMESTAMP - INTERVAL '2 hours', 'The amount invoiced for fixing application issues was $500 more than allowed by the contract.', FALSE),
    (4, CURRENT_TIMESTAMP - INTERVAL '2 hours', 'Lots of mistakes. Returning to vendor for corrections', FALSE),
    (4, CURRENT_TIMESTAMP, 'Everything fix. All good.', TRUE);

CREATE SEQUENCE IF NOT EXISTS invoice_validation_results_id_seq;
SELECT setval('invoice_validation_results_id_seq', COALESCE((SELECT MAX(id) FROM invoice_validation_results), 1) + 1);
ALTER TABLE invoice_validation_results ALTER COLUMN id SET DEFAULT nextval('invoice_validation_results_id_seq');


/* END INVOICES */


/* COPILOT CHAT HISTORY */

CREATE TABLE IF NOT EXISTS copilot_chat_sessions (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    datestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS copilot_chat_session_history (
    id BIGSERIAL PRIMARY KEY,
    copilot_chat_session_id BIGINT NOT NULL,
    role VARCHAR(50) NOT NULL,
    content TEXT,
    datestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* END COPILOT CHAT HISTORY */
