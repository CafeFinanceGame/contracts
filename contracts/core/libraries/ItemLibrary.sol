// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ItemLibrary {
    struct Item {
        address owner;
        ItemType itemType;
        uint256 amount;
    }

    enum ItemType {
        PRODUCT,
        EVENT
    }

    enum CompanyType {
        UNKNOWN,
        FACTORY_COMPANY, // Only system has role this
        COFFEE_COMPANY,
        MACHINE_COMPANY,
        MATERIAL_COMPANY
    }

    enum ProductItemType {
        UNKNOWN,
        // Coffee Company
        COFFEE_BEAN, // Default material product that only coffee company can import
        COFFEE, // Formula: Coffee Bean + Water + Kettle
        // Material Company
        WATER, // Default material product that only material company can import
        MILK, // Formula: Water + Kettle
        // Machine Company
        MACHINE_MATERIAL, // Default material product that only machine company can import
        KETTLE // Formula: Machine Material + Water
    }

    enum EventItemType {
        UNKNOWN,
        SUPPLY_FLUCTUATION,
        WEATHER_VARIATION
    }
}
