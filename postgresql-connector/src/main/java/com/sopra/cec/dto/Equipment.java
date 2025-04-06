package com.sopra.cec.dto;

public record Equipment(
    String id,
    String ip,
    String type,
    String location,
    String status
) {}
