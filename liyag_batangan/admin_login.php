<?php

session_start();

// Replace these credentials with your actual admin credentials or DB check
$valid_username = "admin";
$valid_password = "admin123";

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $username = $_POST["username"] ?? "";
    $password = $_POST["password"] ?? "";

    if ($username === $valid_username && $password === $valid_password) {
        $_SESSION["admin_logged_in"] = true;
        header("Location: admin_business.php");
        exit;
    } else {
        $error = "Invalid credentials. Try again.";
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin Login</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
  <style>
    body {
      background: #8e8888;
      min-height: 100vh;
      margin: 0;
      display: flex;
      justify-content: center;
      align-items: center;
      font-family: 'Poppins', Arial, sans-serif;
    }
    .container {
      background: #111;
      border-radius: 24px;
      width: 430px;
      padding: 48px 36px 36px 36px;
      box-shadow: 0 4px 24px rgba(0,0,0,0.18);
      display: flex;
      flex-direction: column;
      align-items: stretch;
    }
    .container h1 {
      font-size: 2.4rem;
      font-weight: 800;
      margin: 0 0 18px 0;
      text-align: center;
      letter-spacing: 2px;
      color: #fff;
      line-height: 1.1;
    }
    .container p {
      color: #888;
      font-size: 1.08rem;
      text-align: center;
      margin-bottom: 28px;
    }
    .form-group {
      margin-bottom: 22px;
      position: relative;
    }
    .form-group label {
      font-size: 1.05rem;
      font-weight: 500;
      margin-bottom: 8px;
      display: block;
      color: #fff;
    }
    .form-group input {
      width: 100%;
      padding: 13px 44px 13px 44px;
      border: none;
      border-radius: 10px;
      font-size: 1.08rem;
      background: rgba(60,70,90,0.85);
      color: #fff;
      outline: none;
      transition: box-shadow 0.2s;
      box-sizing: border-box;
      box-shadow: 0 0 0 2px transparent;
    }
    .form-group input:focus {
      box-shadow: 0 0 0 2px #ffd600;
      background: rgba(60,70,90,1);
    }
    .form-group .fa {
      position: absolute;
      left: 16px;
      top: 50%;
      transform: translateY(-50%);
      color: #c0c7d1;
      font-size: 1.2rem;
      pointer-events: none;
    }
    .form-group .fa-eye, .form-group .fa-eye-slash {
      right: 16px;
      left: auto;
      cursor: pointer;
      top: 50%;
      transform: translateY(-50%);
      pointer-events: auto;
      color: #c0c7d1;
    }
    .btn-signin {
      width: 100%;
      background: #ffd600;
      color: #222;
      font-weight: 700;
      font-size: 1.18rem;
      border: none;
      border-radius: 10px;
      padding: 15px 0;
      margin-bottom: 18px;
      cursor: pointer;
      transition: background 0.2s;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
    }
    .btn-signin:hover {
      background: #ffb300;
    }
    .divider {
      display: flex;
      align-items: center;
      text-align: center;
      margin: 18px 0 14px 0;
    }
    .divider::before, .divider::after {
      content: '';
      flex: 1;
      border-bottom: 1.5px solid #e0e0e0;
    }
    .divider:not(:empty)::before {
      margin-right: 10px;
    }
    .divider:not(:empty)::after {
      margin-left: 10px;
    }
    .social-login {
      display: flex;
      gap: 12px;
      margin-bottom: 18px;
      justify-content: center;
    }
    .social-btn {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      border: 1.5px solid #e0e0e0;
      border-radius: 8px;
      background: #fafafa;
      padding: 10px 0;
      font-size: 1rem;
      color: #444;
      cursor: pointer;
      transition: background 0.2s, border 0.2s;
      text-decoration: none;
    }
    .social-btn:hover {
      background: #f5f5f5;
      border: 1.5px solid #ffd600;
    }
    .signup {
      text-align: center;
      font-size: 1rem;
      color: #888;
    }
    .signup a {
      color: #ffd600;
      text-decoration: none;
      font-weight: 600;
      margin-left: 4px;
      transition: color 0.2s;
    }
    .signup a:hover {
      color: #ffb300;
    }
    .error {
      color: #e74c3c;
      background: #fff3f3;
      border: 1px solid #ffd6d6;
      border-radius: 6px;
      padding: 8px 0;
      text-align: center;
      margin-bottom: 14px;
      font-size: 0.98rem;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>LIYAG BATANGAN APP</h1>
    <?php if (isset($error)): ?>
      <div class="error"><?= $error ?></div>
    <?php endif; ?>
    <form method="POST" autocomplete="off">
      <div class="form-group">
        <label for="username">Admin</label>
        <i class="fa fa-envelope"></i>
        <input type="text" id="username" name="username" placeholder="Enter your email" required>
      </div>
      <div class="form-group" style="position:relative;">
        <label for="password">Password</label>
        <i class="fa fa-lock"></i>
        <input type="password" id="password" name="password" placeholder="Enter your password" required>
        <i class="fa fa-eye" id="togglePassword"></i>
      </div>
        <button type="submit" class="btn-signin">Sign In <i class="fa fa-arrow-right"></i></button>
        <div class="social-login">
        </div>
    </form>
  </div>
  <script>
    // Toggle password visibility
    const passwordInput = document.getElementById('password');
    const togglePassword = document.getElementById('togglePassword');
    togglePassword.addEventListener('click', function () {
      const type = passwordInput.type === 'password' ? 'text' : 'password';
      passwordInput.type = type;
      this.classList.toggle('fa-eye');
      this.classList.toggle('fa-eye-slash');
    });
  </script>
</body>
</html>