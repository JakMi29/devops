package com.example.RestaurantManagementSystem.infrastructure.database.repository.mapper;

import com.example.RestaurantManagementSystem.domain.User;
import com.example.RestaurantManagementSystem.infrastructure.security.UserEntity;
import org.springframework.stereotype.Component;

@Component
public class UserEntityMapper {
    public User map(UserEntity entity) {
        return User.builder()
                .id(entity.getId())
                .email(entity.getEmail())
                .phone(entity.getPhone())
                .name(entity.getName())
                .surname(entity.getSurname())
                .active(entity.getActive())
                .role(entity.getRole())
                .password(entity.getPassword())
                .build();
    }

    public UserEntity map(User user) {
        return UserEntity.builder()
                .id(user.getId())
                .email(user.getEmail())
                .phone(user.getPhone())
                .name(user.getName())
                .role(user.getRole())
                .surname(user.getSurname())
                .active(user.getActive())
                .password(user.getPassword())
                .build();
    }
}
