const operationInput = document.getElementById("operation");
const num1Input = document.getElementById("num1");
const num2Input = document.getElementById("num2");
const num2Label = document.getElementById("num2Label");
const resultBox = document.getElementById("result");
const calculateButton = document.getElementById("calculateButton");

operationInput.addEventListener("change", updateSecondNumberField);
calculateButton.addEventListener("click", calculate);

function updateSecondNumberField() {
  const isSquareRoot = operationInput.value === "sqrt";
  num2Input.disabled = isSquareRoot;
  num2Label.classList.toggle("muted", isSquareRoot);
}

function showResult(message) {
  resultBox.textContent = message;
  resultBox.classList.remove("error");
}

function showError(message) {
  resultBox.textContent = message;
  resultBox.classList.add("error");
}

function calculate() {
  const num1Value = num1Input.value;
  const num2Value = num2Input.value;
  const operation = operationInput.value;
  let result;

  if (num1Value === "") {
    showError("Please enter the first number.");
    return;
  }

  if (operation !== "sqrt" && num2Value === "") {
    showError("Please enter the second number.");
    return;
  }

  const num1 = Number(num1Value);
  const num2 = Number(num2Value);

  if (operation === "add") {
    result = num1 + num2;
  } else if (operation === "subtract") {
    result = num1 - num2;
  } else if (operation === "multiply") {
    result = num1 * num2;
  } else if (operation === "divide") {
    if (num2 === 0) {
      showError("Cannot divide by zero.");
      return;
    }
    result = num1 / num2;
  } else if (operation === "sqrt") {
    if (num1 < 0) {
      showError("Square root needs a non-negative number.");
      return;
    }
    result = Math.sqrt(num1);
  }

  showResult(`Result: ${result}`);
}

updateSecondNumberField();
