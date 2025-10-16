package com.example.RestaurantManagementSystem.domain;

import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Value;
import lombok.With;

import java.util.List;

@Value
@With
@Builder
@EqualsAndHashCode
public class Table {
    Integer id;
    String name;
    TableStatus status;
    Boolean creatingOrder;
    Boolean active;
    Restaurant restaurant;
    Order order;
}
