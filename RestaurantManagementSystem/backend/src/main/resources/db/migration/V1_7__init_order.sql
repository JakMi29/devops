CREATE TABLE _order (
    id                     SERIAL                  NOT NULL,
    received_date_time     TIMESTAMP WITH TIME ZONE,
    completed_date_time    TIMESTAMP WITH TIME ZONE,
    order_number           VARCHAR(30)             NOT NULL,
    price                  NUMERIC(19, 2)          NOT NULL,
    status                 VARCHAR(20)             NOT NULL,
    edit                   BOOLEAN,
    editor_id              INT,
    waiter_id              INT                     NOT NULL,
    table_id               INT                     NOT NULL,
    customers_quantity     INT                    NOT NULL,
    restaurant_id          INT                     NOT NULL,

    PRIMARY KEY (id),

    UNIQUE (order_number),

    CONSTRAINT fk_waiter_id
        FOREIGN KEY (waiter_id)
            REFERENCES waiter (id),

    CONSTRAINT fk_table_id
        FOREIGN KEY (table_id)
            REFERENCES _table (id),

    CONSTRAINT fk_restaurant_id
        FOREIGN KEY (restaurant_id)
            REFERENCES restaurant (id)
);

CREATE UNIQUE INDEX unique_table_id_non_paid
    ON _order (table_id, status)
    WHERE status <> 'PAID';