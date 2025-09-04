// main.js

document.addEventListener('DOMContentLoaded', () => {
    const contactForm = document.getElementById('contact-form');
    
    if (contactForm) {
        contactForm.addEventListener('submit', (event) => {
            event.preventDefault();
            const formData = new FormData(contactForm);
            const data = Object.fromEntries(formData.entries());

            // Here you can add functionality to send the form data to a server or process it
            console.log('Form submitted:', data);
            alert('Thank you for your message!');
            contactForm.reset();
        });
    }

    // Add any additional interactive functionality here
});