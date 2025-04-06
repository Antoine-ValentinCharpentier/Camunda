package com.sopra.cec.services;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class EquipmentService {

//    @Autowired
//    private EquipmentRepository repository;

    public void select(Long id) {
//        return repository.findById(id).orElse(null);
        System.out.println("SELECT user");
    }

    public void insert(Map<String, Object> data) {
//        Equipment eq = mapToEquipment(data);
//        return repository.save(eq);
        System.out.println("INSERT user");
    }

    public void update(Map<String, Object> data) {
//        Equipment eq = mapToEquipment(data);
//        return repository.save(eq); // save fait insert ou update
        System.out.println("UPDATE user");
    }

    public void delete(Long id) {
        System.out.println("DELETE user "+id);
//        repository.deleteById(id);
    }

//    private Equipment mapToEquipment(Map<String, Object> data) {
//        Equipment eq = new Equipment();
//        if (data.get("id") != null) eq.setId(Long.valueOf(data.get("id").toString()));
//        if (data.get("ip") != null) eq.setIp(data.get("ip").toString());
//        if (data.get("location") != null) eq.setLocation(data.get("location").toString());
//        if (data.get("status") != null) eq.setStatus(data.get("status").toString());
//        if (data.get("type") != null) eq.setType(data.get("type").toString());
//        return eq;
//    }
}
