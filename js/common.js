
document.addEventListener('DOMContentLoaded', function() {
    const mobileNavToggle = document.getElementById('mobile-nav-toggle');
    const sidebar = document.getElementById('sidebar');
    const navOverlay = document.getElementById('nav-overlay');
    const sidebarClose = document.getElementById('sidebar-close');
    
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
        document.body.style.overflow = 'hidden';
    }
    
    function closeMobileNav() {
        sidebar.classList.remove('open');
        navOverlay.classList.remove('active');
        mobileNavToggle.classList.remove('active');
        document.body.style.overflow = '';
    }
    
    if (mobileNavToggle) {
        mobileNavToggle.addEventListener('click', toggleMobileNav);
    }
    
    if (sidebarClose) {
        sidebarClose.addEventListener('click', closeMobileNav);
    }
    
    if (navOverlay) {
        navOverlay.addEventListener('click', closeMobileNav);
    }
    
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            if (window.innerWidth <= 768) {
                closeMobileNav();
            }
        });
    });
    
    window.addEventListener('resize', () => {
        if (window.innerWidth > 768) {
            closeMobileNav();
        }
    });
    
    // Hide/show mobile nav toggle on scroll
    let lastScrollY = window.scrollY;
    let isScrollingDown = false;
    
    window.addEventListener('scroll', () => {
        const currentScrollY = window.scrollY;
        
        // Only apply scroll behavior on mobile
        if (window.innerWidth <= 768) {
            if (currentScrollY > lastScrollY && currentScrollY > 100) {
                // Scrolling down and past 100px - hide menu
                if (!isScrollingDown) {
                    mobileNavToggle.style.transform = 'translateY(-100px)';
                    mobileNavToggle.style.opacity = '0';
                    isScrollingDown = true;
                }
            } else if (currentScrollY < lastScrollY || currentScrollY <= 50) {
                // Scrolling up or near top - show menu
                if (isScrollingDown) {
                    mobileNavToggle.style.transform = 'translateY(0)';
                    mobileNavToggle.style.opacity = '1';
                    isScrollingDown = false;
                }
            }
        } else {
            // On desktop, ensure menu is visible
            mobileNavToggle.style.transform = 'translateY(0)';
            mobileNavToggle.style.opacity = '1';
        }
        
        lastScrollY = currentScrollY;
    });
    
    const currentPage = window.location.pathname.split('/').pop() || 'index.html';
    
    navLinks.forEach(link => {
        if (link.getAttribute('href') === currentPage) {
            link.classList.add('active');
        }
    });
    
    // Check for map page - handle both 'map' and 'map.html'
    if (currentPage === 'map.html' || currentPage === 'map' || window.location.pathname.includes('/map')) {
        document.body.classList.add('map-page');
    }
    
    const currentYear = new Date().getFullYear();
    const footer = document.querySelector('footer');
    if (footer) {
        footer.innerHTML = footer.innerHTML.replace('© by', `© ${currentYear} by`);
    }
});