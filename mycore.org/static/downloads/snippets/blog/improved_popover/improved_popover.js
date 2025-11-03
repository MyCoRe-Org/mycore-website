function initPopovers() {
  document.querySelectorAll('[id^="btn_ir_popover_"]').forEach(function(popoverTriggerEl) {
    const closeBtn = '<button type="button" class="btn-close float-end" aria-label="Close"'
                     +' data-ir-popover-trigger="#' + popoverTriggerEl.id + '"></button>';
    let popover = new bootstrap.Popover(popoverTriggerEl, {
      trigger: 'hover',
      customClass: 'ir-popover',
      delay: {
        "show": 0,
        "hide": 3000
      },
      html: true,
      content: function() {
        const titleTemplateId = popoverTriggerEl.dataset.irPopoverTitleTemplate?.replace('#', '');
        const bodyTemplateId = popoverTriggerEl.dataset.irPopoverBodyTemplate?.replace('#', '');
        if(bodyTemplateId) {
          const bodyTemplate = document.getElementById(bodyTemplateId);
          if(!titleTemplateId) {
            return '<div>' + closeBtn + bodyTemplate.innerHTML + '</div>';
          }
          return '<div>' + bodyTemplate.innerHTML + '</div>';
        }
      },
      title: function() {
        const titleTemplateId = popoverTriggerEl.dataset.irPopoverTitleTemplate?.replace('#', '');
        if(titleTemplateId) {
          const titleTemplate = document.getElementById(titleTemplateId);
          return '<div>' + closeBtn + titleTemplate.innerHTML + '</div>';
        }
        return '';
      },
      container: 'body',
      sanitize: false
    });

    popoverTriggerEl.addEventListener('click', (event) => {
      const popover = bootstrap.Popover.getOrCreateInstance(event.target)
      if (popoverTriggerEl.dataset.irPopoverClicked == "true") {
        delete popoverTriggerEl.dataset.irPopoverClicked;
        popoverTriggerEl.classList.remove("active");
        popover.hide();
      } else {
        popoverTriggerEl.dataset.irPopoverClicked = "true";
        popoverTriggerEl.classList.add("active");
        popover.show();
      }
    });

    popoverTriggerEl.addEventListener('hide.bs.popover', (event) => {
      if (popoverTriggerEl.dataset.irPopoverClicked == "true") {
        event.preventDefault();
      }
    });
  });

  document.addEventListener('click', (eventClick) => {
    const targetEl = eventClick.target;
    const idTriggerEl = targetEl.dataset.irPopoverTrigger?.replace("#", "");
    if (targetEl.classList.contains("btn-close") && idTriggerEl) {
      const triggerEl = document.getElementById(idTriggerEl);
      delete triggerEl.dataset.irPopoverClicked;
      triggerEl.classList.remove("active");
      const popover = bootstrap.Popover.getOrCreateInstance(triggerEl);
      popover.hide();
    }
  });
}