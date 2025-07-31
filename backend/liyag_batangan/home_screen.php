<?php
// home.php
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Liyag Batangan UI</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <!-- Font Awesome -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <style>
    body {
  margin: 0;
  font-family: 'Segoe UI', sans-serif;
  background: #fdfdfd;
}

.app-container {
  max-width: 1200px;
  margin: 40px auto;
  padding: 20px;
  border-radius: 20px;
  box-shadow: 0 0 20px rgba(0,0,0,0.1);
  background-color: #ffffff;
}

.header {
  background: #FFD700;
  padding: 20px;
  color: black;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-radius: 12px;
}

.header .greeting span {
  font-weight: bold;
}

.user-icon i {
  font-size: 24px;
}

.search-bar {
  background: #FFD700;
  padding: 20px;
  border-radius: 12px;
  margin-top: 20px;
}

.search-bar input {
  width: 100%;
  padding: 15px 20px;
  border-radius: 25px;
  border: none;
  font-size: 18px;
}

.categories {
  display: flex;
  justify-content: flex-start;
  gap: 20px;
  padding: 20px 0;
}

.category {
  text-align: center;
  background: #f1f1f1;
  padding: 15px;
  border-radius: 12px;
  width: 100px;
  font-size: 14px;
  cursor: pointer;
}

.category.active {
  background: #FFD700;
  font-weight: bold;
}

.section {
  padding: 20px 0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.store-list,
.recommended-list {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
}

.store-card,
.product-card {
  background: #fff;
  padding: 15px;
  border-radius: 12px;
  width: 250px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
  flex-shrink: 0;
}

.store-card img,
.product-card img {
  width: 100%;
  border-radius: 10px;
  object-fit: cover;
}

.product-card button {
  background: #FFD700;
  border: none;
  padding: 10px;
  border-radius: 8px;
  width: 100%;
  margin-top: 10px;
  font-size: 14px;
  cursor: pointer;
}

  </style>
</head>
<body>
  <div class="app-container">
    
    <!-- Header -->
    <div class="header">
      <div class="greeting">Hello, <span>Customer
    
      </span></div>
      <div class="user-icon"><i class="fas fa-user-circle"></i></div>
    </div>

    <!-- Search Bar -->
    <div class="search-bar">
      <input type="text" placeholder="Discover more" />
    </div>

    <!-- Categories -->
    <div class="categories">
      <div class="category active">🛒<br/>All</div>
      <div class="category">🍽️<br/>Food</div>
      <div class="category">🥤<br/>Beverages</div>
      <div class="category">🎁<br/>Souvenirs</div>
    </div>

    <!-- Checkout Stores Section -->
    <section class="section">
      <div class="section-header">
        <h3>Checkout Stores</h3>
        <a href="#">See All</a>
      </div>
      <div class="store-list">
        <div class="store-card">
          <img src="https://via.placeholder.com/140x100" alt="Store 1">
          <h4>Bahay Kubo PG</h4>
          <p>Brgy. Kumintang</p>
        </div>
        <div class="store-card">
          <img src="https://via.placeholder.com/140x100" alt="Store 2">
          <h4>Lemnor Lomi House</h4>
          <p>Brgy. Pallocan</p>
        </div>
      </div>
    </section>

    <!-- Recommended for You Section -->
    <section class="section">
      <div class="section-header">
        <h3>Recommended for You</h3>
        <a href="#">See All</a>
      </div>
      <div class="recommended-list">
        <div class="product-card">
          <img src="https://via.placeholder.com/120" alt="Lomi" />
          <h4>Lomi</h4>
          <p>₱60</p>
          <button>Add to Cart</button>
        </div>
        <div class="product-card">
          <img src="https://via.placeholder.com/120" alt="Suman" />
          <h4>Suman</h4>
          <p>₱50</p>
          <button>Add to Cart</button>
        </div>
        <div class="product-card">
          <img src="https://via.placeholder.com/120" alt="Goto" />
          <h4>Goto</h4>
          <p>₱70</p>
          <button>Add to Cart</button>
        </div>
      </div>
    </section>

  </div>
</body>
</html>
