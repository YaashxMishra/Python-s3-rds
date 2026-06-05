[33mcommit 4c323c97e270a09681231351ef6947895bb575ea[m[33m ([m[1;36mHEAD[m[33m -> [m[1;32mmain[m[33m, [m[1;31morigin/main[m[33m, [m[1;31morigin/HEAD[m[33m)[m
Author:     rajendra0968jangid <rajendra0968jangid@gmail.com>
AuthorDate: Thu Feb 12 15:14:50 2026 +0530
Commit:     rajendra0968jangid <rajendra0968jangid@gmail.com>
CommitDate: Thu Feb 12 15:14:50 2026 +0530

    code

[1mdiff --git a/__pycache__/config.cpython-312.pyc b/__pycache__/config.cpython-312.pyc[m
[1mnew file mode 100644[m
[1mindex 0000000..fa2a301[m
Binary files /dev/null and b/__pycache__/config.cpython-312.pyc differ
[1mdiff --git a/app.py b/app.py[m
[1mnew file mode 100644[m
[1mindex 0000000..d0e3d90[m
[1m--- /dev/null[m
[1m+++ b/app.py[m
[36m@@ -0,0 +1,100 @@[m
[32m+[m[32mfrom flask import Flask, render_template, request, redirect, session, url_for[m
[32m+[m[32mfrom flask_mysqldb import MySQL[m
[32m+[m[32mimport boto3[m
[32m+[m[32mfrom config import Config[m
[32m+[m[32mimport uuid[m
[32m+[m
[32m+[m[32mapp = Flask(__name__)[m
[32m+[m[32mapp.config.from_object(Config)[m
[32m+[m
[32m+[m[32mmysql = MySQL(app)[m
[32m+[m
[32m+[m[32m# S3 Client[m
[32m+[m[32ms3 = boto3.client([m
[32m+[m[32m    "s3",[m
[32m+[m[32m    aws_access_key_id=app.config["AWS_ACCESS_KEY_ID"],[m
[32m+[m[32m    aws_secret_access_key=app.config["AWS_SECRET_ACCESS_KEY"],[m
[32m+[m[32m    region_name=app.config["AWS_REGION"][m
[32m+[m[32m)[m
[32m+[m
[32m+[m[32m# ===================== SIGNUP =====================[m
[32m+[m[32m@app.route("/signup", methods=["GET", "POST"])[m
[32m+[m[32mdef signup():[m
[32m+[m[32m    if request.method == "POST":[m
[32m+[m[32m        name = request.form["name"][m
[32m+[m[32m        email = request.form["email"][m
[32m+[m[32m        password = request.form["password"][m
[32m+[m[32m        file = request.files["avatar"][m
[32m+[m
[32m+[m[32m        filename = str(uuid.uuid4()) + file.filename[m
[32m+[m
[32m+[m[32m        s3.upload_fileobj([m
[32m+[m[32m                file,[m
[32m+[m[32m                app.config["AWS_BUCKET_NAME"],[m
[32m+[m[32m                filename[m
[32m+[m[32m        )[m
[32m+[m
[32m+[m
[32m+[m[32m        avatar_url = f"https://{app.config['AWS_BUCKET_NAME']}.s3.amazonaws.com/{filename}"[m
[32m+[m
[32m+[m[32m        cur = mysql.connection.cursor()[m
[32m+[m[32m        cur.execute([m
[32m+[m[32m            "INSERT INTO users(name,email,password,avatar_url) VALUES(%s,%s,%s,%s)",[m
[32m+[m[32m            (name, email, password, avatar_url)[m
[32m+[m[32m        )[m
[32m+[m[32m        mysql.connection.commit()[m
[32m+[m[32m        cur.close()[m
[32m+[m
[32m+[m[32m        return redirect("/signin")[m
[32m+[m
[32m+[m[32m    return render_template("signup.html")[m
[32m+[m
[32m+[m
[32m+[m[32m# ===================== SIGNIN =====================[m
[32m+[m[32m@app.route("/signin", methods=["GET", "POST"])[m
[32m+[m[32mdef signin():[m
[32m+[m[32m    if request.method == "POST":[m
[32m+[m[32m        email = request.form["email"][m
[32m+[m[32m        password = request.form["password"][m
[32m+[m
[32m+[m[32m        cur = mysql.connection.cursor()[m
[32m+[m[32m        cur.execute([m
[32m+[m[32m            "SELECT * FROM users WHERE email=%s AND password=%s",[m
[32m+[m[32m            (email, password)[m
[32m+[m[32m        )[m
[32m+[m[32m        user = cur.fetchone()[m
[32m+[m[32m        cur.close()[m
[32m+[m
[32m+[m[32m        if user:[m
[32m+[m[32m            session["user_id"] = user[0][m
[32m+[m[32m            session["name"] = user[1][m
[32m+[m[32m            session["avatar"] = user[4][m
[32m+[m[32m            return redirect("/home")[m
[32m+[m
[32m+[m[32m        return "Invalid Credentials"[m
[32m+[m
[32m+[m[32m    return render_template("signin.html")[m
[32m+[m
[32m+[m
[32m+[m[32m# ===================== HOME =====================[m
[32m+[m[32m@app.route("/home")[m
[32m+[m[32mdef home():[m
[32m+[m[32m    if "user_id" not in session:[m
[32m+[m[32m        return redirect("/signin")[m
[32m+[m
[32m+[m[32m    return render_template([m
[32m+[m[32m        "home.html",[m
[32m+[m[32m        name=session["name"],[m
[32m+[m[32m        avatar=session["avatar"][m
[32m+[m[32m    )[m
[32m+[m
[32m+[m
[32m+[m[32m# ===================== LOGOUT =====================[m
[32m+[m[32m@app.route("/logout")[m
[32m+[m[32mdef logout():[m
[32m+[m[32m    session.clear()[m
[32m+[m[32m    return redirect("/signin")[m
[32m+[m
[32m+[m
[32m+[m[32mif __name__ == "__main__":[m
[32m+[m[32m    app.run(debug=True)[m
[1mdiff --git a/config.py b/config.py[m
[1mnew file mode 100644[m
[1mindex 0000000..9bd13dc[m
[1m--- /dev/null[m
[1m+++ b/config.py[m
[36m@@ -0,0 +1,15 @@[m
[32m+[m[32mimport os[m
[32m+[m
[32m+[m[32mclass Config:[m
[32m+[m[32m    SECRET_KEY = "your_secret_key"[m
[32m+[m
[32m+[m[32m    MYSQL_HOST = "localhost"[m
[32m+[m[32m    MYSQL_USER = "root"[m
[32m+[m[32m    MYSQL_PASSWORD = "your_mysql_password"[m
[32m+[m[32m    MYSQL_DB = "flask_auth"[m
[32m+[m
[32m+[m[32m    # AWS S3[m
[32m+[m[32m    AWS_ACCESS_KEY_ID = "your_access_key"[m
[32m+[m[32m    AWS_SECRET_ACCESS_KEY = "your_secret_key"[m
[32m+[m[32m    AWS_BUCKET_NAME = "your_bucket_name"[m
[32m+[m[32m    AWS_REGION = "ap-south-1"[m
[1mdiff --git a/requirements.txt b/requirements.txt[m
[1mnew file mode 100644[m
[1mindex 0000000..5d3095c[m
[1m--- /dev/null[m
[1m+++ b/requirements.txt[m
[36m@@ -0,0 +1,16 @@[m
[32m+[m[32mFlask[m
[32m+[m[32mflask-mysqldb[m
[32m+[m[32mboto3[m
[32m+[m[32mpython-dotenv[m
[32m+[m
[32m+[m[32m# CREATE DATABASE flask_auth;[m
[32m+[m
[32m+[m[32m# USE flask_auth;[m
[32m+[m
[32m+[m[32m# CREATE TABLE users ([m
[32m+[m[32m#     id INT AUTO_INCREMENT PRIMARY KEY,[m
[32m+[m[32m#     name VARCHAR(100),[m
[32m+[m[32m#     email VARCHAR(100) UNIQUE,[m
[32m+[m[32m#     password VARCHAR(255),[m
[32m+[m[32m#     avatar_url TEXT[m
[32m+[m[32m# );[m
[1mdiff --git a/templates/home.html b/templates/home.html[m
[1mnew file mode 100644[m
[1mindex 0000000..748f7a0[m
[1m--- /dev/null[m
[1m+++ b/templates/home.html[m
[36m@@ -0,0 +1,64 @@[m
[32m+[m[32m<!DOCTYPE html>[m
[32m+[m[32m<html>[m
[32m+[m[32m<head>[m
[32m+[m[32m    <title>Home</title>[m
[32m+[m[32m    <style>[m
[32m+[m[32m        body {[m
[32m+[m[32m            margin: 0;[m
[32m+[m[32m            padding: 0;[m
[32m+[m[32m            font-family: Arial, sans-serif;[m
[32m+[m[32m            background: linear-gradient(135deg, #667eea, #764ba2);[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            justify-content: center;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            height: 100vh;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .card {[m
[32m+[m[32m            background: white;[m
[32m+[m[32m            padding: 30px;[m
[32m+[m[32m            border-radius: 15px;[m
[32m+[m[32m            text-align: center;[m
[32m+[m[32m            box-shadow: 0 10px 25px rgba(0,0,0,0.2);[m
[32m+[m[32m            width: 350px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .avatar {[m
[32m+[m[32m            width: 150px;[m
[32m+[m[32m            height: 150px;[m
[32m+[m[32m            border-radius: 50%;[m
[32m+[m[32m            object-fit: cover;[m
[32m+[m[32m            border: 5px solid #667eea;[m
[32m+[m[32m            margin-bottom: 15px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        h2 {[m
[32m+[m[32m            margin-bottom: 15px;[m
[32m+[m[32m            color: #333;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .logout-btn {[m
[32m+[m[32m            display: inline-block;[m
[32m+[m[32m            padding: 10px 20px;[m
[32m+[m[32m            background: #ff4b5c;[m
[32m+[m[32m            color: white;[m
[32m+[m[32m            text-decoration: none;[m
[32m+[m[32m            border-radius: 8px;[m
[32m+[m[32m            transition: 0.3s;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .logout-btn:hover {[m
[32m+[m[32m            background: #e63e4d;[m
[32m+[m[32m        }[m
[32m+[m[32m    </style>[m
[32m+[m[32m</head>[m
[32m+[m[32m<body>[m
[32m+[m
[32m+[m[32m    <div class="card">[m
[32m+[m[32m        <img src="{{ avatar }}" class="avatar">[m
[32m+[m[32m        <h2>Welcome {{ name }}</h2>[m
[32m+[m[32m        <a href="/logout" class="logout-btn">Logout</a>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m</body>[m
[32m+[m[32m</html>[m
[1mdiff --git a/templates/signin.html b/templates/signin.html[m
[1mnew file mode 100644[m
[1mindex 0000000..cad5b64[m
[1m--- /dev/null[m
[1m+++ b/templates/signin.html[m
[36m@@ -0,0 +1,113 @@[m
[32m+[m[32m<!DOCTYPE html>[m
[32m+[m[32m<html>[m
[32m+[m[32m<head>[m
[32m+[m[32m    <title>Signin</title>[m
[32m+[m[32m    <style>[m
[32m+[m[32m        body {[m
[32m+[m[32m            margin: 0;[m
[32m+[m[32m            padding: 0;[m
[32m+[m[32m            font-family: Arial, sans-serif;[m
[32m+[m[32m            background: linear-gradient(135deg, #667eea, #764ba2);[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            justify-content: center;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            height: 100vh;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .card {[m
[32m+[m[32m            background: white;[m
[32m+[m[32m            padding: 35px;[m
[32m+[m[32m            border-radius: 15px;[m
[32m+[m[32m            width: 350px;[m
[32m+[m[32m            box-shadow: 0 10px 25px rgba(0,0,0,0.2);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        h2 {[m
[32m+[m[32m            text-align: center;[m
[32m+[m[32m            margin-bottom: 25px;[m
[32m+[m[32m            color: #333;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .input-group {[m
[32m+[m[32m            margin-bottom: 18px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .input-group label {[m
[32m+[m[32m            display: block;[m
[32m+[m[32m            margin-bottom: 5px;[m
[32m+[m[32m            font-weight: 600;[m
[32m+[m[32m            color: #555;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .input-group input {[m
[32m+[m[32m            width: 100%;[m
[32m+[m[32m            padding: 10px;[m
[32m+[m[32m            border-radius: 8px;[m
[32m+[m[32m            border: 1px solid #ccc;[m
[32m+[m[32m            outline: none;[m
[32m+[m[32m            transition: 0.3s;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .input-group input:focus {[m
[32m+[m[32m            border-color: #667eea;[m
[32m+[m[32m            box-shadow: 0 0 5px rgba(102,126,234,0.5);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .btn {[m
[32m+[m[32m            width: 100%;[m
[32m+[m[32m            padding: 10px;[m
[32m+[m[32m            border: none;[m
[32m+[m[32m            border-radius: 8px;[m
[32m+[m[32m            background: #667eea;[m
[32m+[m[32m            color: white;[m
[32m+[m[32m            font-size: 16px;[m
[32m+[m[32m            cursor: pointer;[m
[32m+[m[32m            transition: 0.3s;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .btn:hover {[m
[32m+[m[32m            background: #5a67d8;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .signup-link {[m
[32m+[m[32m            text-align: center;[m
[32m+[m[32m            margin-top: 15px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .signup-link a {[m
[32m+[m[32m            color: #667eea;[m
[32m+[m[32m            text-decoration: none;[m
[32m+[m[32m            font-weight: 600;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .signup-link a:hover {[m
[32m+[m[32m            text-decoration: underline;[m
[32m+[m[32m        }[m
[32m+[m[32m    </style>[m
[32m+[m[32m</head>[m
[32m+[m[32m<body>[m
[32m+[m
[32m+[m[32m    <div class="card">[m
[32m+[m[32m        <h2>Sign In</h2>[m
[32m+[m
[32m+[m[32m        <form method="POST">[m
[32m+[m[32m            <div class="input-group">[m
[32m+[m[32m                <label>Email</label>[m
[32m+[m[32m                <input type="email" name="email" required>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <div class="input-group">[m
[32m+[m[32m                <label>Password</label>[m
[32m+[m[32m                <input type="password" name="password" required>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <button type="submit" class="btn">Login</button>[m
[32m+[m[32m        </form>[m
[32m+[m
[32m+[m[32m        <div class="signup-link">[m
[32m+[m[32m            Don't have an account? <a href="/signup">Create Account</a>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m</body>[m
[32m+[m[32m</html>[m
[1mdiff --git a/templates/signup.html b/templates/signup.html[m
[1mnew file mode 100644[m
[1mindex 0000000..f90f242[m
[1m--- /dev/null[m
[1m+++ b/templates/signup.html[m
[36m@@ -0,0 +1,158 @@[m
[32m+[m[32m<!DOCTYPE html>[m
[32m+[m[32m<html>[m
[32m+[m[32m<head>[m
[32m+[m[32m    <title>Signup</title>[m
[32m+[m[32m    <style>[m
[32m+[m[32m        body {[m
[32m+[m[32m            margin: 0;[m
[32m+[m[32m            padding: 0;[m
[32m+[m[32m            font-family: Arial, sans-serif;[m
[32m+[m[32m            background: linear-gradient(135deg, #667eea, #764ba2);[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            justify-content: center;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            height: 100vh;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .card {[m
[32m+[m[32m            background: white;[m
[32m+[m[32m            padding: 35px;[m
[32m+[m[32m            border-radius: 15px;[m
[32m+[m[32m            width: 380px;[m
[32m+[m[32m            box-shadow: 0 10px 25px rgba(0,0,0,0.2);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        h2 {[m
[32m+[m[32m            text-align: center;[m
[32m+[m[32m            margin-bottom: 25px;[m
[32m+[m[32m            color: #333;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .input-group {[m
[32m+[m[32m            margin-bottom: 18px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .input-group label {[m
[32m+[m[32m            display: block;[m
[32m+[m[32m            margin-bottom: 6px;[m
[32m+[m[32m            font-weight: 600;[m
[32m+[m[32m            color: #555;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .input-group input {[m
[32m+[m[32m            width: 100%;[m
[32m+[m[32m            padding: 10px;[m
[32m+[m[32m            border-radius: 8px;[m
[32m+[m[32m            border: 1px solid #ccc;[m
[32m+[m[32m            outline: none;[m
[32m+[m[32m            transition: 0.3s;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .input-group input:focus {[m
[32m+[m[32m            border-color: #667eea;[m
[32m+[m[32m            box-shadow: 0 0 5px rgba(102,126,234,0.5);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .file-input {[m
[32m+[m[32m            border: none;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .btn {[m
[32m+[m[32m            width: 100%;[m
[32m+[m[32m            padding: 10px;[m
[32m+[m[32m            border: none;[m
[32m+[m[32m            border-radius: 8px;[m
[32m+[m[32m            background: #667eea;[m
[32m+[m[32m            color: white;[m
[32m+[m[32m            font-size: 16px;[m
[32m+[m[32m            cursor: pointer;[m
[32m+[m[32m            transition: 0.3s;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .btn:hover {[m
[32m+[m[32m            background: #5a67d8;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .signin-link {[m
[32m+[m[32m            text-align: center;[m
[32m+[m[32m            margin-top: 15px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .signin-link a {[m
[32m+[m[32m            color: #667eea;[m
[32m+[m[32m            text-decoration: none;[m
[32m+[m[32m            font-weight: 600;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .signin-link a:hover {[m
[32m+[m[32m            text-decoration: underline;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .avatar-preview {[m
[32m+[m[32m            text-align: center;[m
[32m+[m[32m            margin-bottom: 15px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .avatar-preview img {[m
[32m+[m[32m            width: 90px;[m
[32m+[m[32m            height: 90px;[m
[32m+[m[32m            border-radius: 50%;[m
[32m+[m[32m            object-fit: cover;[m
[32m+[m[32m            border: 3px solid #667eea;[m
[32m+[m[32m            display: none;[m
[32m+[m[32m        }[m
[32m+[m[32m    </style>[m
[32m+[m[32m</head>[m
[32m+[m[32m<body>[m
[32m+[m
[32m+[m[32m    <div class="card">[m
[32m+[m[32m        <h2>Create Account</h2>[m
[32m+[m
[32m+[m[32m        <form method="POST" enctype="multipart/form-data">[m
[32m+[m[41m            [m
[32m+[m[32m            <div class="avatar-preview">[m
[32m+[m[32m                <img id="preview">[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <div class="input-group">[m
[32m+[m[32m                <label>Name</label>[m
[32m+[m[32m                <input type="text" name="name" required>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <div class="input-group">[m
[32m+[m[32m                <label>Email</label>[m
[32m+[m[32m                <input type="email" name="email" required>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <div class="input-group">[m
[32m+[m[32m                <label>Password</label>[m
[32m+[m[32m                <input type="password" name="password" required>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <div class="input-group">[m
[32m+[m[32m                <label>Avatar</label>[m
[32m+[m[32m                <input type="file" name="avatar" id="avatarInput" required>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <button type="submit" class="btn">Signup</button>[m
[32m+[m[32m        </form>[m
[32m+[m
[32m+[m[32m        <div class="signin-link">[m
[32m+[m[32m            Already have an account? <a href="/signin">Signin</a>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m<script>[m
[32m+[m[32m    // Avatar preview before upload[m
[32m+[m[32m    document.getElementById("avatarInput").addEventListener("change", function(event) {[m
[32m+[m[32m        const file = event.target.files[0];[m
[32m+[m[32m        if (file) {[m
[32m+[m[32m            const preview = document.getElementById("preview");[m
[32m+[m[32m            preview.src = URL.createObjectURL(file);[m
[32m+[m[32m            preview.style.display = "block";[m
[32m+[m[32m        }[m
[32m+[m[32m    });[m
[32m+[m[32m</script>[m
[32m+[m
[32m+[m[32m</body>[m
[32m+[m[32m</html>[m
