String? nameValidator(String? value) {
  Pattern pattern = r'^[a-zA-Z0-9/s]+$';
  Pattern pattern2 = r'^([0-9])+[a-zA-Z0-9/s]+$';
  RegExp regex = new RegExp(pattern.toString());
  RegExp regex2 = new RegExp(pattern2.toString());
  if (value!.isEmpty)
    return 'Name should not be empty';
  else if (!regex.hasMatch(value))
    return 'Name should not contain special character';
  else if (regex2.hasMatch(value))
    return 'Name should not start with alpanumerics';
  else if (value.length <= 3)
    return "Name should have more than 3 characters";
  else
    return null;
}

String? emailValidator(String? value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern.toString());
  if (!regex.hasMatch(value!))
    return 'Enter Valid email';
  else
    return null;
}

String? passwordValidator(String? value) {
  Pattern pattern =
      r'^(((?=.*[a-z])(?=.*[A-Z]))|((?=.*[a-z])(?=.*[0-9]))|((?=.*[A-Z])(?=.*[0-9])))(?=.{6,})';
  RegExp regex = new RegExp(pattern.toString());
  if (!regex.hasMatch(value!))
    return 'Enter valid password';
  else
    return null;
}

String? addressValidator(String? value) {
  Pattern pattern = r'^[0-9a-zA-Z,/. ]+$';
  RegExp regex = new RegExp(pattern.toString());
  if (value!.isEmpty)
    return 'Address should not be empty';
  else if (!regex.hasMatch(value))
    return 'Address should have only [,/. ] special characters';
  else if (value.length <= 8)
    return "Address should have more than 8 characters";
  else
    return null;
}

String? cityValidator(String? value) {
  Pattern pattern = r'^[a-zA-Z]+$';
  RegExp regex = new RegExp(pattern.toString());
  if (value!.isEmpty)
    return 'City should not be empty';
  else if (!regex.hasMatch(value))
    return 'City should not contain special characters';
  else if (value.length <= 2)
    return "City should have more than 2 characters";
  else
    return null;
}

String? contactValidator(String? value) {
  Pattern pattern = r'^[0-9]{10}$';
  RegExp regex = new RegExp(pattern.toString());
  if (value!.isEmpty)
    return 'Contact should not be empty';
  else if (!regex.hasMatch(value))
    return 'Contact should only 10 contain numbers';
  else
    return null;
}

String? validatePassword(String? value) {
  if (value!.isEmpty)
    return 'Please enter password';
  else
    return null;
}

String? passwordNewValidator(String? value) {
  Pattern pattern =
      r'^(((?=.*[a-z])(?=.*[A-Z]))|((?=.*[a-z])(?=.*[0-9]))|((?=.*[A-Z])(?=.*[0-9])))(?=.{6,})';
  RegExp regex = new RegExp(pattern.toString());
  if (!regex.hasMatch(value!))
    return 'Enter valid password';
  else
    return null;
}

String? newPasswordValidator(String? value) {
  Pattern pattern =
      r'^(((?=.*[a-z])(?=.*[A-Z]))|((?=.*[a-z])(?=.*[0-9]))|((?=.*[A-Z])(?=.*[0-9])))(?=.{6,})';
  RegExp regex = new RegExp(pattern.toString());
  if (!regex.hasMatch(value!))
    return 'Enter valid password';
  else
    return null;
}

String? oldPasswordValidator(String? value) {
  if (value == "" || value == null) {
    return "Please enter old password";
  }
  return null;
}

String? roomValidator(String? val, String? ignoreName) {
  RegExp roomNamePattern = new RegExp(r"^(([A-Za-z]+)([1-9]*))$");
  if (val!.isEmpty) {
    return 'Please enter home name.';
  } else if (!roomNamePattern.hasMatch(val) ||
      val.length < 4 ||
      val.length > 16) {
    return "Home Name invalid.";
  } else {
    return null;
  }
}

String? homeValidator(String? val, String? ignoreName) {
  RegExp homeNamePattern = new RegExp(r"^(([A-Za-z]+)([1-9]*))$");
  if (val!.isEmpty) {
    return 'Please enter home name.';
  } else if (!homeNamePattern.hasMatch(val) ||
      val.length < 3 ||
      val.length > 8) {
    return "Home Name invalid.";
  } else {
    return null;
  }
}

String? deviceValidator(String? val, String? ignoreName) {
  RegExp homeNamePattern = new RegExp(r"^(([A-Za-z]+)([1-9]*))$");
  if (val!.isEmpty) {
    return 'Please enter home name.';
  } else if (!homeNamePattern.hasMatch(val) ||
      val.length < 3 ||
      val.length > 8) {
    return "Home Name invalid.";
  } else {
    return null;
  }
}
