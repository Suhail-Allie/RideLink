# RideLink – Taxi Booking MVP

RideLink is a Flutter taxi booking application designed for small taxi and transport businesses. The goal of the app is to give local taxi businesses a simple digital system where customers can request rides, drivers can manage trips, and business owners can view booking activity.

This project is currently an MVP version. It is being built step by step as a foundation for a future Uber-like taxi booking platform.

---

## Project Purpose

Many small taxi businesses still rely on phone calls, WhatsApp messages, or manual booking books to manage rides. RideLink aims to make the booking process more organised and professional by giving the business a digital system for handling customer ride requests.

The app supports three main user roles:

- Customer
- Driver
- Admin / Business Owner

---

## Current MVP Features

### Customer Features

Customers can:

- Register with basic details
- Log in
- View a customer dashboard
- Book a new taxi ride
- Enter pickup location
- Enter destination
- Select ride date and time using a date/time picker
- Enter trip distance
- View an estimated fare
- Submit a booking
- View their booking history
- See trip status updates

---

### Driver Features

Drivers can:

- Log in through the driver login screen
- View customer ride requests
- See pickup and destination details
- See customer phone number
- See trip date and time
- See estimated fare
- Accept a ride
- Start a trip
- Complete a trip
- Cancel a trip

Driver status updates are saved and shown to the customer and admin.

---

### Admin / Business Owner Features

Admins can:

- Log in through the admin login screen
- View an owner dashboard
- See total bookings
- See active trips
- See completed trips
- See cancelled trips
- View estimated revenue
- View all bookings
- Clear demo booking data
- Open pricing settings
- Set the base fare
- Set the price per kilometre

---

## Fare Estimate

RideLink calculates an estimated fare using:

```text
Estimated Fare = Base Fare + (Distance × Price Per KM)