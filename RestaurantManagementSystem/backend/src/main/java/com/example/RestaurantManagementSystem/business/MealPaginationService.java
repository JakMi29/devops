package com.example.RestaurantManagementSystem.business;

import com.example.RestaurantManagementSystem.api.dto.MealDTO;
import com.example.RestaurantManagementSystem.api.dto.TableOrderMealDTO;
import com.example.RestaurantManagementSystem.domain.Meal;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;


@Service
@AllArgsConstructor
public class MealPaginationService {
    private final MealService mealService;

    public Page<MealDTO> findAllByCategory(
            String restaurantName,
            String category,
            int pageNumber,
            int pageSize,
            String searchTerm,
            List<String> excludesNames

    ) {
        Sort sort = Sort.by(
                Sort.Order.desc("mealOfTheDay"),
                Sort.Order.asc("name")
        );
        Pageable pageable = PageRequest.of(pageNumber, pageSize, sort);
        return mealService.findAllByCategory(
                restaurantName,
                category,
                pageable,
                searchTerm,
                excludesNames
        );
    }
}
