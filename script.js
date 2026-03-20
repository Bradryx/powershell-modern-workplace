(() => {
  const searchInput = document.getElementById("search");
  const searchClear = document.getElementById("search-clear");
  const filterTabs = document.getElementById("filter-tabs");
  const noResults = document.getElementById("no-results");
  const cards = Array.from(document.querySelectorAll(".card"));
  const moduleGroups = Array.from(document.querySelectorAll(".module-group"));

  let activeFilter = "all";
  let searchQuery = "";

  function normalize(str) {
    return str.toLowerCase().replace(/[^a-z0-9\s-]/g, "");
  }

  function applyFilters() {
    let visibleCount = 0;

    cards.forEach((card) => {
      const module = card.dataset.module;
      const tags = normalize(card.dataset.tags || "");
      const name = normalize(card.querySelector(".card-name")?.textContent || "");
      const desc = normalize(card.querySelector("p")?.textContent || "");

      const matchesFilter = activeFilter === "all" || module === activeFilter;
      const matchesSearch =
        !searchQuery ||
        name.includes(searchQuery) ||
        tags.includes(searchQuery) ||
        desc.includes(searchQuery);

      const visible = matchesFilter && matchesSearch;
      card.classList.toggle("hidden", !visible);
      if (visible) visibleCount++;
    });

    // Show/hide module groups based on visible cards
    moduleGroups.forEach((group) => {
      const module = group.dataset.module;
      const hasVisible = cards.some(
        (c) => c.dataset.module === module && !c.classList.contains("hidden")
      );
      group.classList.toggle("hidden", !hasVisible);
    });

    noResults.classList.toggle("hidden", visibleCount > 0);
  }

  // Search
  searchInput.addEventListener("input", () => {
    searchQuery = normalize(searchInput.value);
    searchClear.classList.toggle("visible", searchQuery.length > 0);
    applyFilters();
  });

  searchClear.addEventListener("click", () => {
    searchInput.value = "";
    searchQuery = "";
    searchClear.classList.remove("visible");
    searchInput.focus();
    applyFilters();
  });

  // Filter tabs
  filterTabs.addEventListener("click", (e) => {
    const tab = e.target.closest(".tab");
    if (!tab) return;

    activeFilter = tab.dataset.filter;
    filterTabs.querySelectorAll(".tab").forEach((t) => t.classList.remove("active"));
    tab.classList.add("active");
    applyFilters();
  });

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener("click", (e) => {
      const target = document.querySelector(anchor.getAttribute("href"));
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: "smooth", block: "start" });
      }
    });
  });
})();
