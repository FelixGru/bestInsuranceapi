--liquibase formatted sql
----changeset jpa_dev:001-ddl-definition.sql splitStatements:false
-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Countries Table
-- Stores information about different countries.
CREATE TABLE Countries (
    country_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(64) NOT NULL,
    population INT
);

-- States Table
-- Stores information about states or regions within countries.
CREATE TABLE States (
    state_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID NOT NULL,
    name VARCHAR(64) NOT NULL,
    population INT,
    CONSTRAINT fk_country_states FOREIGN KEY (country_id) REFERENCES Countries(country_id)
);

-- Cities Table
-- Stores information about cities within states and countries.
CREATE TABLE Cities (
    city_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID NOT NULL,
    state_id UUID, -- Can be NULL if a country doesn't have states or for direct city-country relation
    name VARCHAR(64) NOT NULL,
    population INT,
    CONSTRAINT fk_country_cities FOREIGN KEY (country_id) REFERENCES Countries(country_id),
    CONSTRAINT fk_state_cities FOREIGN KEY (state_id) REFERENCES States(state_id)
);

-- Addresses Table
-- Stores detailed address information, linked to countries, states, and cities.
CREATE TABLE Addresses (
    address_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID NOT NULL,
    city_id UUID NOT NULL,
    state_id UUID, -- Can be NULL
    address VARCHAR(128) NOT NULL,
    postal_code VARCHAR(16),
    CONSTRAINT fk_country_addresses FOREIGN KEY (country_id) REFERENCES Countries(country_id),
    CONSTRAINT fk_city_addresses FOREIGN KEY (city_id) REFERENCES Cities(city_id),
    CONSTRAINT fk_state_addresses FOREIGN KEY (state_id) REFERENCES States(state_id)
);

-- Customers Table
-- Stores information about customers.
CREATE TABLE Customers (
    customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(64) NOT NULL,
    surname VARCHAR(64) NOT NULL,
    email VARCHAR(320) NOT NULL UNIQUE, -- Email should be unique
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    address_id UUID, -- A customer might not have an address initially or it's optional
    CONSTRAINT fk_address_customers FOREIGN KEY (address_id) REFERENCES Addresses(address_id)
);

-- Policies Table
-- Stores information about insurance policies.
CREATE TABLE Policies (
    policy_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(16) NOT NULL, -- Diagram shows VARCHAR(16), seems short for a policy name, consider increasing.
    description TEXT,
    price NUMERIC(4,2) NOT NULL, -- Assuming this is a base price or a general price. Max value 99.99
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Coverages Table
-- Stores different types of coverages available.
CREATE TABLE Coverages (
    coverage_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(16) NOT NULL, -- Diagram shows VARCHAR(16), seems short for a coverage name.
    description TEXT
);

-- Policies_Coverages Table (Junction Table)
-- Links Policies with their respective Coverages (Many-to-Many relationship).
CREATE TABLE Policies_Coverages (
    coverage_id UUID NOT NULL,
    policy_id UUID NOT NULL,
    PRIMARY KEY (coverage_id, policy_id), -- Composite primary key
    CONSTRAINT fk_coverage_pc FOREIGN KEY (coverage_id) REFERENCES Coverages(coverage_id) ON DELETE CASCADE,
    CONSTRAINT fk_policy_pc FOREIGN KEY (policy_id) REFERENCES Policies(policy_id) ON DELETE CASCADE
);

-- Subscriptions Table
-- Stores information about customer subscriptions to policies.
CREATE TABLE Subscriptions (
    policy_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    paid_price NUMERIC(4,2) NOT NULL, -- Max value 99.99
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (policy_id, customer_id, start_date), -- Composite key to allow multiple subscriptions over time for the same policy/customer
    CONSTRAINT fk_policy_subscriptions FOREIGN KEY (policy_id) REFERENCES Policies(policy_id),
    CONSTRAINT fk_customer_subscriptions FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT chk_dates CHECK (end_date >= start_date) -- Ensure end_date is not before start_date
);

-- Triggers to automatically update 'updated_at' timestamps

-- Function to update 'updated_at' timestamp
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for Customers table
CREATE TRIGGER set_timestamp_customers
BEFORE UPDATE ON Customers
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

-- Trigger for Policies table
CREATE TRIGGER set_timestamp_policies
BEFORE UPDATE ON Policies
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

-- Trigger for Subscriptions table
CREATE TRIGGER set_timestamp_subscriptions
BEFORE UPDATE ON Subscriptions
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

-- Comments on potential improvements based on the diagram:
-- 1. Policies.name VARCHAR(16) and Coverages.name VARCHAR(16) might be too short. Consider VARCHAR(64) or VARCHAR(128).
-- 2. Policies.price NUMERIC(4,2) and Subscriptions.paid_price NUMERIC(4,2) allows a maximum value of 99.99. This might be too low for insurance prices.
--    Consider NUMERIC(10,2) for values up to 99,999,999.99 or adjust as needed.
-- 3. The relationship between Cities and States: The diagram shows FK state_id in Cities. This implies a city belongs to one state.
--    It also shows FK country_id in Cities. This is good.
-- 4. The relationship between Addresses and States: FK state_id is nullable, which is fine if some addresses are in regions without states.
-- 5. Consider adding indexes on foreign key columns and frequently queried columns for performance.
--    Example: CREATE INDEX idx_customers_email ON Customers(email);
--             CREATE INDEX idx_subscriptions_customer_id ON Subscriptions(customer_id);
--             CREATE INDEX idx_subscriptions_policy_id ON Subscriptions(policy_id);

