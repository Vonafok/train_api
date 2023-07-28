package com.example.train_api.entity;

public class Ticket {

    private Long bookingId;
    private Long boughtplaceId;

    public Ticket(Long bookingId, Long boughtplaceId) {
        this.bookingId = bookingId;
        this.boughtplaceId = boughtplaceId;
    }

    public Ticket() {
    }

    public Long getBookingId() {
        return bookingId;
    }

    public Long getBoughtplaceId() {
        return boughtplaceId;
    }

    public void setBookingId(Long bookingId) {
        this.bookingId = bookingId;
    }

    public void setBoughtplaceId(Long boughtplaceId) {
        this.boughtplaceId = boughtplaceId;
    }
}
