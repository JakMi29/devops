package com.example.RestaurantManagementSystem.api.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.validation.annotation.Validated;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Validated
public class WaiterDTO {
    String email;
    String phone;
    String name;
    String surname;
    String salary;
    String employmentDate;
}
