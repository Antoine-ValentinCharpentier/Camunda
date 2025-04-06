package com.sopra.cec.dto;

import jakarta.validation.constraints.NotEmpty;

public record PostgresqlConnectorRequest(@NotEmpty String operation, Equipment equipment) {}

