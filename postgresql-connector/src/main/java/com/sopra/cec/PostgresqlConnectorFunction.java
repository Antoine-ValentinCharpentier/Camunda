package com.sopra.cec;

import com.sopra.cec.dto.Equipment;
import com.sopra.cec.services.EquipmentService;
import io.camunda.connector.api.annotation.OutboundConnector;
import io.camunda.connector.api.error.ConnectorException;
import io.camunda.connector.api.outbound.OutboundConnectorContext;
import io.camunda.connector.api.outbound.OutboundConnectorFunction;
import io.camunda.connector.generator.java.annotation.ElementTemplate;

import com.sopra.cec.dto.PostgresqlConnectorRequest;
import com.sopra.cec.dto.PostgresqlConnectorResult;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

@OutboundConnector(
    name = "Postgresql Connector",
    inputVariables = {"operation", "equipment"},
    type = "com.sopra.cec:postgresql:1"
)
@ElementTemplate(
    id = "com.sopra.cec.PostgresqlConnectorTemplate.v1",
    name = "Postgresql Connector",
    version = 1,
    inputDataClass = PostgresqlConnectorRequest.class
)
public class PostgresqlConnectorFunction implements OutboundConnectorFunction {

  @Autowired
  private EquipmentService equipmentService;

  private static final Logger LOGGER = LoggerFactory.getLogger(PostgresqlConnectorFunction.class);

  @Override
  public Object execute(OutboundConnectorContext context) {
    System.out.println(">>> CONNECTOR ACTIVATED !!!");
    System.out.println(context.getJobContext().getVariables());
    final var connectorRequest = context.bindVariables(PostgresqlConnectorRequest.class);
    return executeConnector(connectorRequest);
  }

  private PostgresqlConnectorResult executeConnector(PostgresqlConnectorRequest req) {
    String operation = req.operation().toUpperCase();
    Equipment data = req.equipment();

    return switch (operation) {
      case "SELECT" -> {
        Long id = Long.valueOf(data.id());
//        var result = equipmentService.select(id);
//        yield new PostgresqlConnectorResult(result != null ? result.toString() : "Not found");
        yield new PostgresqlConnectorResult("SELECT");
      }
      case "INSERT" -> {
//        var result = equipmentService.insert(data);
//        yield new PostgresqlConnectorResult("Inserted: " + result);
        yield new PostgresqlConnectorResult("INSERT");
      }
      case "UPDATE" -> {
//        var result = equipmentService.update(data);
//        yield new PostgresqlConnectorResult("Updated: " + result);
        yield new PostgresqlConnectorResult("UPDATE");
      }
      case "DELETE" -> {
//        Long id = Long.valueOf(data.get("id").toString());
//        equipmentService.delete(id);
//        yield new PostgresqlConnectorResult("Deleted equipment with id " + id);
        yield new PostgresqlConnectorResult("DELETE");
      }
      default -> throw new ConnectorException("BAD_OP", "Unsupported operation: " + operation);
    };
  }
}