(() => {
  "use strict";

  const fileInput = document.querySelector("#fileToUpload");
  const pasteZone = document.querySelector("#pasteZone");
  const uploadStatus = document.querySelector("#uploadStatus");

  if (!fileInput || !pasteZone || !uploadStatus) return;

  const maxUploadSize = Number(fileInput.dataset.maxSize);

  const showSelectedFile = (file) => {
    if (file.size > maxUploadSize) {
      fileInput.value = "";
      pasteZone.classList.remove("has-file");
      uploadStatus.classList.add("is-error");
      uploadStatus.textContent = "This image is larger than the 32 MB upload limit.";
      return false;
    }

    pasteZone.classList.add("has-file");
    uploadStatus.classList.remove("is-error");
    uploadStatus.textContent = `${file.name} is ready to upload.`;
    return true;
  };

  fileInput.addEventListener("change", () => {
    const file = fileInput.files[0];

    if (file) {
      showSelectedFile(file);
    } else {
      pasteZone.classList.remove("has-file");
      uploadStatus.classList.remove("is-error");
      uploadStatus.textContent = "";
    }
  });

  document.addEventListener("paste", (event) => {
    const item = Array.from(event.clipboardData?.items || []).find((candidate) =>
      candidate.type.startsWith("image/")
    );

    if (!item) {
      uploadStatus.classList.add("is-error");
      uploadStatus.textContent = "The clipboard does not contain an image.";
      return;
    }

    const image = item.getAsFile();
    if (!image) return;

    const subtype = image.type.split("/")[1] || "png";
    const extension = subtype === "jpeg" ? "jpg" : subtype.replace(/[^a-z0-9]/gi, "");
    const file = new File([image], `clipboard-image.${extension || "png"}`, {type: image.type});
    if (!showSelectedFile(file)) return;

    const transfer = new DataTransfer();

    transfer.items.add(file);
    fileInput.files = transfer.files;
    event.preventDefault();
  });
})();
