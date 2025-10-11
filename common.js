// Common JavaScript functionality for the internal reference site

// Mobile navigation functionality
document.addEventListener('DOMContentLoaded', function() {
    const mobileNavToggle = document.getElementById('mobile-nav-toggle');
    const sidebar = document.getElementById('sidebar');
    const navOverlay = document.getElementById('nav-overlay');
    const sidebarClose = document.getElementById('sidebar-close');
    
    // Toggle mobile navigation
    function toggleMobileNav() {
        const isOpen = sidebar.classList.contains('open');
        
        if (isOpen) {
            closeMobileNav();
        } else {
            openMobileNav();
        }
    }
    
    function openMobileNav() {
        sidebar.classList.add('open');
        navOverlay.classList.add('active');
        mobileNavToggle.classList.add('active');
        document.body.style.overflow = 'hidden'; // Prevent body scroll
    }
    
    function closeMobileNav() {
        sidebar.classList.remove('open');
        navOverlay.classList.remove('active');
        mobileNavToggle.classList.remove('active');
        document.body.style.overflow = ''; // Restore body scroll
    }
    
    // Event listeners
    if (mobileNavToggle) {
        mobileNavToggle.addEventListener('click', toggleMobileNav);
    }
    
    if (sidebarClose) {
        sidebarClose.addEventListener('click', closeMobileNav);
    }
    
    if (navOverlay) {
        navOverlay.addEventListener('click', closeMobileNav);
    }
    
    // Close mobile nav when clicking on nav links
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            if (window.innerWidth <= 768) {
                closeMobileNav();
            }
        });
    });
    
    // Close mobile nav on window resize if screen becomes large
    window.addEventListener('resize', () => {
        if (window.innerWidth > 768) {
            closeMobileNav();
        }
    });
    
    // Highlight the active navigation link based on current page
    const currentPage = window.location.pathname.split('/').pop() || 'index.html';
    
    navLinks.forEach(link => {
        if (link.getAttribute('href') === currentPage) {
            link.classList.add('active');
        }
    });
    
    // Add map-page class if this is the map page
    if (currentPage === 'map.html') {
        document.body.classList.add('map-page');
    }
});
