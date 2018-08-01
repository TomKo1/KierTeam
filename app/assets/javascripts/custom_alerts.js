$(function() {
    window.alert = function(msg) {
        $(this.document.createElement('div')).html(msg)
            .dialog({
                buttons: [
                    {
                    text: 'OK',
                    click: function() {$(this).dialog('close');},
                    class: 'btn btn-success'
                    },
                    {
                        text: 'Cancel',
                        click: function(){$(this).dialog('close');console.log('Easter egg! :)');},
                        class: 'btn btn-danger'
                    }
                ],
                modal: true,
                width: 'auto',
                resizable: false,
                title: 'Warning',
                draggable: true
            });
    }

    // override confirm window
    window.confirm = function(msg){

    }
});