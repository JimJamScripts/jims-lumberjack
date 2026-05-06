let currentTab = "storage";

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "open") {
        document.getElementById("ui").classList.remove("hidden");
        switchTab("storage");
    }

    if (data.action === "close") {
        document.getElementById("ui").classList.add("hidden");
    }

    if (data.action === "updateStorage") {
        renderStorage(data.items, data.capacity);
    }

    if (data.action === "updateShopfront") {
        renderShopfront(data.items, data.balance, data.canManage);
    }

    if (data.action === "updateProcessing") {
        renderProcessing(data);
    }

    if (data.action === "updateDeliveries") {
        renderDeliveries(data);
    }

    if (data.action === "updateOffice") {
        renderOffice(data);
    }
});

/* CLOSE BUTTON */
document.getElementById("closeBtn").addEventListener("click", () => {
    fetch(`https://${GetParentResourceName()}/closeUI`, { method: "POST" });
    document.getElementById("ui").classList.add("hidden");
});

/* TAB SWITCHING */
document.querySelectorAll(".tab").forEach(tab => {
    tab.addEventListener("click", () => {
        switchTab(tab.dataset.tab);
    });
});

function switchTab(tab) {
    currentTab = tab;

    document.querySelectorAll(".tab").forEach(t => t.classList.remove("active"));
    document.querySelector(`.tab[data-tab="${tab}"]`).classList.add("active");

    document.querySelectorAll(".panel").forEach(p => p.classList.add("hidden"));
    document.getElementById(`${tab}Panel`).classList.remove("hidden");
}

/* STORAGE RENDER */
function renderStorage(items, capacity) {
    const panel = document.getElementById("storagePanel");
    panel.innerHTML = `<h2>Storage (${Object.values(items).reduce((a,b)=>a+b,0)}/${capacity})</h2>`;

    let html = `<div class="grid">`;
    for (let item in items) {
        html += `
            <div class="slot">
                <div>${item}</div>
                <div class="count">${items[item]}</div>
            </div>
        `;
    }
    html += `</div>`;

    panel.innerHTML += html;
}

/* SHOPFRONT RENDER */
function renderShopfront(items, balance, canManage) {
    const panel = document.getElementById("shopfrontPanel");
    panel.innerHTML = `<h2>Shopfront — Balance: $${balance}</h2>`;

    let html = `<div class="grid">`;
    for (let item in items) {
        html += `
            <div class="slot">
                <div>${item}</div>
                <div class="count">${items[item].stock}</div>
            </div>
        `;
    }
    html += `</div>`;

    panel.innerHTML += html;
}

/* PROCESSING */
function renderProcessing(data) {
    document.getElementById("processingPanel").innerHTML = `
        <h2>Processing</h2>
        <p>Input: ${data.input}</p>
        <p>Output: ${data.output}</p>
    `;
}

/* DELIVERIES */
function renderDeliveries(data) {
    document.getElementById("deliveriesPanel").innerHTML = `
        <h2>Deliveries</h2>
        <p>Route: ${data.route}</p>
        <p>Items: ${data.items}</p>
        <p>Payout: $${data.payout}</p>
    `;
}

/* OFFICE */
function renderOffice(data) {
    const panel = document.getElementById("officePanel");
    panel.innerHTML = `<h2>Office</h2>`;

    panel.innerHTML += `<h3>Employees</h3>`;
    for (let id in data.employees) {
        panel.innerHTML += `<p>${data.employees[id].name} — Rank ${data.employees[id].rank}</p>`;
    }
}
