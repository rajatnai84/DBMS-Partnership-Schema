CREATE TYPE type_enum AS ENUM ('internal', 'external');

CREATE TABLE roles(role_id SERIAL PRIMARY KEY, title VARCHAR(100) NOT NULL, type type_enum NOT NULL DEFAULT 'internal');

CREATE TABLE domains(domain_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL);

CREATE TABLE company(company_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, domain_id INT,FOREIGN KEY (domain_id) REFERENCES domains (domain_id) ON DELETE SET NULL);

CREATE TABLE users(user_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, company_id INT, role_id INT, FOREIGN KEY (company_id) REFERENCES company (company_id) ON DELETE SET NULL, FOREIGN KEY (role_id) REFERENCES roles (role_id));

CREATE TABLE partnership(partnership_id SERIAL PRIMARY KEY);

CREATE TABLE user_partnership(user_id INT, partnership_id INT, role_id INT, FOREIGN KEY (user_id) REFERENCES 
users (user_id) ON DELETE SET NULL, FOREIGN KEY (partnership_id) REFERENCES 
partnership (partnership_id) ON DELETE SET NULL, FOREIGN KEY (role_id) REFERENCES 
roles (role_id));

CREATE TYPE partnership_role AS ENUM ('lead', 'partner');

CREATE TABLE company_partnership(partnership_id INT, company_id INT, role partnership_role NOT NULL DEFAULT 'partner',
FOREIGN KEY (partnership_id) REFERENCES partnership (partnership_id) ON DELETE SET NULL,
FOREIGN KEY (company_id) REFERENCES company (company_id) ON DELETE SET NULL
);

CREATE TABLE campaigns(campaign_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, start_date TIMESTAMP NOT NULL,
end_date TIMESTAMP NOT NULL, partnership_id INT,
FOREIGN KEY (partnership_id) REFERENCES partnership (partnership_id) ON DELETE SET NULL
);

CREATE TABLE leads(lead_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL,
descrip TEXT NOT NULL, campaign_id INT, FOREIGN KEY (campaign_id) REFERENCES campaigns (campaign_id) ON DELETE SET NULL
);

CREATE TABLE accounts(account_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, website VARCHAR(200) NOT NULL);

CREATE TABLE opportunities(opportunity_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, account_id INT,
amount INT, FOREIGN KEY (account_id) REFERENCES accounts (account_id) ON DELETE SET NULL);

CREATE TABLE solutions(solution_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, descrip TEXT, partnership_id INT,
FOREIGN KEY (partnership_id) REFERENCES partnership (partnership_id) ON DELETE SET NULL);

ALTER TABLE campaigns ADD solution_id INT, 
ADD CONSTRAINT campaign_solution FOREIGN KEY (solution_id) REFERENCES solutions(solution_id);

ALTER TABLE leads ADD solution_id INT, 
ADD CONSTRAINT lead_solution FOREIGN KEY (solution_id) REFERENCES solutions(solution_id);

ALTER TABLE accounts ADD lead_id INT, 
ADD CONSTRAINT account_lead FOREIGN KEY (lead_id) REFERENCES leads(lead_id);

ALTER TABLE opportunities ADD lead_id INT, 
ADD CONSTRAINT opportunity_lead FOREIGN KEY (lead_id) REFERENCES leads(lead_id);


-- 

SELECT partnership_id from user_partnership WHERE user_id = 1;

SELECT users.user_id, users.name, roles.title FROM users INNER JOIN roles ON users.role_id = roles.role_id WHERE users.company_id = 1;

SELECT users.user_id, users.name, roles.type 
FROM users
INNER JOIN user_partnership
ON users.user_id = user_partnership.user_id
INNER JOIN roles
ON roles.role_id = user_partnership.role_id 
WHERE user_partnership.partnership_id = 1;

SELECT * 
FROM company
INNER JOIN company_partnership
ON company.company_id = company_partnership.company_id
INNER JOIN campaigns
ON campaigns.partnership_id = company_partnership.partnership_id
INNER JOIN;

SELECT * FROM 
leads LEFT JOIN opportunities ON leads.lead_id = opportunities.lead_id
LEFT JOIN campaigns ON campaigns.campaign_id = leads.campaign_id 
GROUP BY partnership_id;