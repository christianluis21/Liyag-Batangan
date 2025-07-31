<?php
session_start();
if (!isset($_SESSION["admin_logged_in"]) || $_SESSION["admin_logged_in"] !== true) {
    header("Location: admin_login.php");
    exit;
}

$conn = new mysqli("localhost", "root", "", "liyag_batangan");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Handle review request
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['vendor_id'], $_POST['action'])) {
    $vendor_id = intval($_POST['vendor_id']);
    $action = $_POST['action'];

    if (!in_array($action, ['approve', 'reject'])) {
        echo json_encode(["status" => "error", "message" => "Invalid action"]);
        exit;
    }

    $result = $conn->query("
        SELECT vendor_account.*, users.name AS user_name 
        FROM vendor_account 
        JOIN users ON vendor_account.user_id = users.user_id 
        WHERE vendor_account.vendor_id = $vendor_id
    ");

    if ($result->num_rows === 0) {
        echo json_encode(["status" => "error", "message" => "Vendor not found"]);
        exit;
    }

    $vendor = $result->fetch_assoc();
    $user_id = intval($vendor['user_id']);
    $business_name = $vendor['business_name'];
    $newStatus = $action === 'approve' ? 'approved' : 'rejected';

    $conn->query("UPDATE vendor_account SET status = '$newStatus' WHERE vendor_id = $vendor_id");

    if ($action === 'approve') {
        $title = "✅ Business Approved!";
        $message = "Congratulations! Your business \"$business_name\" has been approved.";
        $conn->query("UPDATE users SET user_type = 'vendor' WHERE user_id = $user_id");
    } else {
        $title = "❌ Business Rejected";
        $message = "We're sorry. Your business \"$business_name\" has been rejected.";
    }

    $stmt = $conn->prepare("INSERT INTO notifications (user_id, title, message) VALUES (?, ?, ?)");
    $stmt->bind_param("iss", $user_id, $title, $message);
    $stmt->execute();
    $stmt->close();

    echo json_encode(["status" => "success", "message" => "Vendor $newStatus and notification sent."]);
    exit;
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin Vendor Review</title>
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
      width: 900px;
      max-width: 98vw;
      padding: 40px 36px;
      box-shadow: 0 4px 24px rgba(0,0,0,0.18);
      display: flex;
      flex-direction: column;
      align-items: stretch;
      margin: 40px 0;
    }
    .header-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 18px;
    }
    .container h1 {
      font-size: 2.2rem;
      font-weight: 800;
      margin: 0 0 8px 0;
      text-align: left;
      letter-spacing: 2px;
      color: #fff;
      line-height: 1.1;
    }
    .logout {
      text-decoration: none;
      color: #ffd600;
      font-weight: 700;
      font-size: 1.1rem;
      background: none;
      border: 2px solid #ffd600;
      border-radius: 8px;
      padding: 8px 18px;
      transition: background 0.2s, color 0.2s;
    }
    .logout:hover {
      background: #ffd600;
      color: #111;
    }
    .vendor-list {
      display: flex;
      flex-wrap: wrap;
      gap: 28px;
      justify-content: flex-start;
      margin-top: 18px;
    }
    .vendor-card {
      background: #232b39;
      border-radius: 14px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.13);
      padding: 22px 18px;
      width: 290px;
      color: #fff;
      display: flex;
      flex-direction: column;
      align-items: stretch;
      transition: transform 0.2s, box-shadow 0.2s;
      position: relative;
    }
    .vendor-card:hover {
      transform: translateY(-4px) scale(1.025);
      box-shadow: 0 6px 18px rgba(0,0,0,0.18);
    }
    .logo {
      width: 100%;
      height: 120px;
      object-fit: cover;
      border-radius: 8px;
      margin-bottom: 12px;
      background: #181d26;
      border: 1px solid #222;
    }
    .vendor-card h2 {
      font-size: 1.18rem;
      font-weight: 700;
      margin: 0 0 6px 0;
      color: #ffd600;
      text-shadow: 0 1px 2px #0002;
    }
    .vendor-card p {
      font-size: 0.98rem;
      color: #e0e0e0;
      margin: 0 0 8px 0;
    }
    .vendor-card .submitted {
      font-size: 0.93rem;
      color: #bdbdbd;
      margin-bottom: 8px;
    }
    .actions {
      display: flex;
      justify-content: space-between;
      margin-top: 12px;
      gap: 10px;
    }
    .actions button {
      flex: 1;
      padding: 10px 0;
      border: none;
      border-radius: 8px;
      font-weight: 700;
      font-size: 1rem;
      cursor: pointer;
      transition: background 0.2s, color 0.2s;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
    }
    .actions button.approve {
      background: #ffd600;
      color: #222;
      border: 2px solid #ffd600;
    }
    .actions button.approve:hover {
      background: #fff;
      color: #111;
      border-color: #ffd600;
    }
    .actions button.reject {
      background: #e74c3c;
      color: #fff;
      border: 2px solid #e74c3c;
    }
    .actions button.reject:hover {
      background: #fff;
      color: #e74c3c;
      border-color: #e74c3c;
    }
    @media (max-width: 1000px) {
      .container { width: 99vw; padding: 18px 2vw; }
      .vendor-list { gap: 16px; }
      .vendor-card { width: 98vw; max-width: 340px; }
    }
    @media (max-width: 600px) {
      .container { width: 100vw; padding: 8px 0; }
      .vendor-list { flex-direction: column; align-items: center; }
      .vendor-card { width: 98vw; max-width: 98vw; }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header-row">
      <h1>🛍️ Liyag Batangan App<br>Pending Vendor Applications</h1>
      <a href="admin-logout.php" class="logout"><i class="fa fa-sign-out-alt"></i> Logout</a>
    </div>
    <div class="vendor-list">
    <?php
    $vendors = $conn->query("
      SELECT vendor_account.*, users.name AS user_name 
      FROM vendor_account 
      JOIN users ON vendor_account.user_id = users.user_id 
      WHERE vendor_account.status = 'pending'
    ");
    while ($vendor = $vendors->fetch_assoc()):
    ?>
      <div class="vendor-card">
        <img src="<?= htmlspecialchars($vendor['logo_url']) ?>" alt="Logo" class="logo">
        <h2><i class="fa fa-store"></i> <?= htmlspecialchars($vendor['business_name']) ?></h2>
        <p><?= htmlspecialchars($vendor['business_description']) ?></p>
        <p><strong><i class="fa fa-user"></i> Submitted by:</strong> <?= htmlspecialchars($vendor['user_name']) ?></p>
        <div class="submitted"><i class="fa fa-calendar-alt"></i> <strong>Submitted:</strong> <?= $vendor['registration_date'] ?></div>
        <div class="actions">
          <button class="approve" onclick="reviewVendor(<?= $vendor['vendor_id'] ?>, 'approve')"><i class="fa fa-check"></i> Approve</button>
          <button class="reject" onclick="reviewVendor(<?= $vendor['vendor_id'] ?>, 'reject')"><i class="fa fa-times"></i> Reject</button>
        </div>
      </div>
    <?php endwhile; ?>
    </div>
  </div>
<script>
  function reviewVendor(vendorId, action) {
    if (!confirm(`Are you sure you want to ${action} this vendor?`)) return;

    const formData = new FormData();
    formData.append('vendor_id', vendorId);
    formData.append('action', action);

    fetch(window.location.href, {
      method: 'POST',
      body: formData
    })
    .then(res => res.json())
    .then(data => {
      alert(data.message);
      if (data.status === 'success') location.reload();
    })
    .catch(err => {
      alert("Something went wrong.");
    });
  }
</script>
</body>
</html>
