/**
 * E-Receipt System - Common JavaScript Utilities
 * Version: 3.2 - Auto-redirect and path detection
 */

// Check if on production and has wrong path - redirect to correct one
if (window.location.hostname !== 'localhost' &&
    window.location.hostname !== '127.0.0.1' &&
    window.location.pathname.includes('/e-receipt/web/')) {
    // Redirect to correct production path
    const correctPath = window.location.pathname.replace('/e-receipt/web/', '/web/');
    window.location.href = window.location.origin + correctPath + window.location.search + window.location.hash;
}

// Auto-detect base path (works for both local and production)
const BASE_PATH = window.location.pathname.includes('/e-receipt/') ? '/e-receipt' : '';
const API_BASE_URL = BASE_PATH + '/api';

// Check if user is logged in
function checkAuth() {
    const user = localStorage.getItem('user');
    if (!user) {
        window.location.href = BASE_PATH + '/web/login.html';
        return null;
    }
    return JSON.parse(user);
}

// Check if user is admin
function checkAdmin() {
    const user = checkAuth();
    if (!user || !user.is_admin) {
        window.location.href = BASE_PATH + '/web/dashboard.html';
        return null;
    }
    return user;
}

// Logout function
async function logout() {
    if (confirm('Are you sure you want to logout?')) {
        try {
            // Call logout API to destroy session
            await fetch(API_BASE_URL + '/auth/logout.php', {
                method: 'POST',
                credentials: 'include'
            });
        } catch (error) {
            console.error('Logout API error:', error);
        }

        // Clear localStorage
        localStorage.removeItem('user');

        // Redirect to login
        window.location.href = BASE_PATH + '/web/login.html';
    }
}

// Show alert message
function showAlert(message, type = 'error', containerId = 'alertContainer') {
    const alertContainer = document.getElementById(containerId);
    if (!alertContainer) return;

    const alertClass = type === 'success' ? 'alert-success' :
                       type === 'warning' ? 'alert-warning' :
                       type === 'info' ? 'alert-info' : 'alert-error';

    const icon = type === 'success'
        ? '<path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>'
        : type === 'warning'
        ? '<path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z"/>'
        : '<path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>';

    alertContainer.innerHTML = `
        <div class="alert ${alertClass}">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                ${icon}
            </svg>
            <span>${message}</span>
        </div>
    `;

    setTimeout(() => {
        alertContainer.innerHTML = '';
    }, 5000);
}

// Format date
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

// Format currency
function formatCurrency(amount) {
    if (!amount) return '-';
    return '$' + parseFloat(amount).toFixed(2);
}

// Get status badge HTML
function getStatusBadge(status) {
    const badges = {
        'pending': '<span class="badge badge-pending">Pending</span>',
        'approved': '<span class="badge badge-approved">Approved</span>',
        'rejected': '<span class="badge badge-rejected">Rejected</span>',
        'active': '<span class="badge badge-approved">Active</span>'
    };
    return badges[status] || status;
}

// Show loading state
function showLoading(buttonId, textId, spinnerId) {
    const button = document.getElementById(buttonId);
    const text = document.getElementById(textId);
    const spinner = document.getElementById(spinnerId);

    if (button) button.disabled = true;
    if (button) button.classList.add('loading');
    if (text) text.classList.add('hidden');
    if (spinner) spinner.classList.remove('hidden');
}

// Hide loading state
function hideLoading(buttonId, textId, spinnerId) {
    const button = document.getElementById(buttonId);
    const text = document.getElementById(textId);
    const spinner = document.getElementById(spinnerId);

    if (button) button.disabled = false;
    if (button) button.classList.remove('loading');
    if (text) text.classList.remove('hidden');
    if (spinner) spinner.classList.add('hidden');
}

// API request helper
async function apiRequest(endpoint, method = 'GET', data = null) {
    const options = {
        method: method,
        credentials: 'include', // Include cookies/session
        headers: {
            'Content-Type': 'application/json'
        }
    };

    if (data && method !== 'GET') {
        options.body = JSON.stringify(data);
    }

    try {
        const response = await fetch(`${API_BASE_URL}${endpoint}`, options);
        const result = await response.json();
        return result;
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
}

// Upload file helper
async function uploadFile(endpoint, formData) {
    try {
        const response = await fetch(`${API_BASE_URL}${endpoint}`, {
            method: 'POST',
            credentials: 'include', // Include cookies/session
            body: formData
        });
        const result = await response.json();
        return result;
    } catch (error) {
        console.error('Upload Error:', error);
        throw error;
    }
}

// Modal functions
function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('active');
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('active');
    }
}

// Update navbar with user info
function updateNavbar(user) {
    const navbarMenu = document.querySelector('.navbar-menu');
    if (navbarMenu && user) {
        const userInfo = `
            <span style="color: #9CA3AF;">Welcome, <strong style="color: var(--primary-orange);">${user.full_name}</strong></span>
            <button onclick="logout()" class="btn btn-secondary btn-sm">Logout</button>
        `;

        const existingUserInfo = navbarMenu.querySelector('.user-info');
        if (existingUserInfo) {
            existingUserInfo.innerHTML = userInfo;
        } else {
            const div = document.createElement('div');
            div.className = 'user-info d-flex align-center gap-2';
            div.innerHTML = userInfo;
            navbarMenu.appendChild(div);
        }
    }
}

// Debounce function for search
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Copy to clipboard
function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        showAlert('Copied to clipboard!', 'success');
    }).catch(err => {
        console.error('Failed to copy:', err);
    });
}

// Confirm dialog
function confirmAction(message, callback) {
    if (confirm(message)) {
        callback();
    }
}

// File size formatter
function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

// Validate file
function validateFile(file, maxSize = 10485760, allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'application/pdf']) {
    if (!file) {
        return { valid: false, message: 'No file selected' };
    }

    if (!allowedTypes.includes(file.type)) {
        return { valid: false, message: 'Only JPG, PNG, GIF images and PDF files are allowed' };
    }

    if (file.size > maxSize) {
        return { valid: false, message: `File size must not exceed ${formatFileSize(maxSize)}` };
    }

    return { valid: true };
}

// Generate unique ID
function generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

// Export functions for use in other scripts
window.appUtils = {
    checkAuth,
    checkAdmin,
    logout,
    showAlert,
    formatDate,
    formatCurrency,
    getStatusBadge,
    showLoading,
    hideLoading,
    apiRequest,
    uploadFile,
    openModal,
    closeModal,
    updateNavbar,
    debounce,
    copyToClipboard,
    confirmAction,
    formatFileSize,
    validateFile,
    generateId
};
