/// Dynamic Bootstrap Modal
var BstrapModal = function (title, body, buttons, on_show_event) {
    var title = title || "Lorem Ipsum History", body = body || "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.", buttons = buttons || [{ Value: "CLOSE", Css: "btn-primary" }];
    var Id = Math.random();
    var GetModalStructure = function () {
        var that = this;
        that.Id = Id;
        var buttonshtml = "";
        for (var i = 0; i < buttons.length; i++) {
            buttonshtml += "<button type='button' class='btn " + (buttons[i].Css || "") + "' name='btn" + that.Id + "'>" + (buttons[i].Value || "CLOSE") + "</button>";
        }
        return "<div class='modal fade' name='dynamiccustommodal' id='" + that.Id + "' tabindex='-1' role='dialog' data-keyboard='true' data-focus='true' aria-labelledby='" + that.Id + "Label'><div class='modal-dialog modal-lg modal-dialog-centered'><div class='modal-content'><div class='modal-header bg-primary'><button type='button' class='close' data-dismiss='modal' title='Close' aria-label='Close'><span aria-hidden='true'>&times;</span></button><h4 class='modal-title'>" + title + "</h4></div><div class='modal-body'><div class='row'><div class='col-xs-12 col-md-12 col-sm-12 col-lg-12'>" + body + "</div></div></div><div class='modal-footer bg-default'><div class='col-xs-12 col-sm-12 col-lg-12'>" + buttonshtml + "</div></div></div></div></div>";
    }();
    this.Delete = function (preservePreviousModals) {
        if (!preservePreviousModals) {
            BstrapModal.Delete();
        } else {
            var modal = document.getElementById(Id);
            if (modal) document.body.removeChild(modal);
        }
    };
    BstrapModal.Delete = function () {
        $('.modal[name="dynamiccustommodal"]').each(function (ix) {
            $(this).remove();
        });
        // forcibly remove backdrop in case we've missed something
        $('body').removeClass('modal-open');
        $('.modal-backdrop').remove();
    };
    this.Close = function (preservePreviousModals) {
        if (!preservePreviousModals)
            BstrapModal.Close;
        else
            $(document.getElementById(Id)).modal('hide');
    };
    BstrapModal.Close = function () {
        $('.modal[name="dynamiccustommodal"]').each( function (ix) { $(this).modal('hide') } );
    };
    this.Show = function (preservePreviousModals) {
        if (!preservePreviousModals)
            this.Delete();

        document.body.appendChild($(GetModalStructure)[0]);
        var btns = document.querySelectorAll("button[name='btn" + Id + "']");
        for (var i = 0; i < btns.length; i++) {
            btns[i].addEventListener("click", buttons[i].Callback || this.Close);
        }

        $(document.getElementById(Id)).modal('show');
        var that = this;
        $(document.getElementById(Id)).on('hidden.bs.modal', function (e) {
            that.Delete(preservePreviousModals);
        });

        if (on_show_event) {
            $(document.getElementById(Id)).on('shown.bs.modal', function (e) {
                on_show_event(e, Id);
            });
        }
    };
};
class respite_crud {
    // Public Members
    dt_Columns;
    dt_Order;
    dt_Buttons;

    dt_InlineActionButtons;
    dt_ToolbarActionButtons;

    respite_editor_options;
    dt;
    row;
    detail_rows;
    DM_form_rendered = false;

    static url_dml_opened = false;

    static edit_button_selector;
    static delete_button_selector;

    static placeholderReplacements = [];

    // Default callback functions

    // pre-submit callback 
    static callbackPreRequest(formData, jqForm, options) {
        // jqForm is a jQuery object encapsulating the form element.  To access the 
        // DOM element for the form do this: 
        var formElement = jqForm[0];

        BstrapModal.Close();

        $(formElement.getAttribute('form-modal')).modal('hide');

        var bsm = new BstrapModal("Processing...", '<h3 class="text-center"><i class="fas fa-spinner fa-pulse"></i></h3>', []);
        bsm.Show();
        //respite_crud.dt.buttons.info('Processing...', '<h3 class="text-center"><i class="fas fa-spinner fa-pulse"></i></h3>');

        // returning anything other than false will allow the form submit to continue 
        return true;
    }

    // post-submit callback 
    static callbackPostResponse(response, statusType, xhr, $form) {
        // for normal html responses, the first argument to the success callback 
        // is the XMLHttpRequest object's responseText property 

        // if the ajaxForm method was passed an Options Object with the dataType 
        // property set to 'xml' then the first argument to the success callback 
        // is the XMLHttpRequest object's responseXML property 

        // if the ajaxForm method was passed an Options Object with the dataType 
        // property set to 'json' then the first argument to the success callback 
        // is the json data object returned by the server 
        var btnsm = '<div class="ml-auto float-right pull-right"><button type="button" role="button" class="btn btn-secondary btn-sm" onclick="respite_crud.dt.buttons.info(false)" aria-label="Close" title="Close"><span aria-hidden="true">&times;</span></button></div>';
        var btn = '<br/><button type="button" role="button" class="btn btn-secondary" onclick="respite_crud.dt.buttons.info(false)">Close</button>';
        var bsm;

        if (statusType == 'error') {
            bsm = new BstrapModal('<i class="fas fa-exclamation-triangle"></i> ' + response.status + ' ' + response.statusText, response.responseText);
            //respite_crud.dt.buttons.info(btnsm + '<i class="fas fa-exclamation-triangle"></i> ' + response.status + ' ' + response.statusText, response.responseText + btn);
        }
        else {
            bsm = new BstrapModal('<i class="fas fa-check-circle"></i> ' + xhr.statusText, response['data']);
            //respite_crud.dt.buttons.info('<i class="fas fa-check-circle"></i> ' + xhr.statusText + btnsm, response['data'] + btn, 10000);
        }

        bsm.Show();

        // refresh datatable:
        respite_crud.dt.ajax.reload();

        //alert('status: ' + statusType + '\n\nresponse: \n' + response['data'] + 
        //    '\n\nThe output div should have already been updated with the responseText.'); 
    }

    // post-submit callback with fast timeout and simple success message
    static callbackPostResponseSimple(response, statusType, xhr, $form) {
        // for normal html responses, the first argument to the success callback 
        // is the XMLHttpRequest object's responseText property 

        // if the ajaxForm method was passed an Options Object with the dataType 
        // property set to 'xml' then the first argument to the success callback 
        // is the XMLHttpRequest object's responseXML property 

        // if the ajaxForm method was passed an Options Object with the dataType 
        // property set to 'json' then the first argument to the success callback 
        // is the json data object returned by the server 
        var btnsm = '<div class="ml-auto float-right pull-right"><button type="button" role="button" class="btn btn-secondary btn-sm" onclick="respite_crud.dt.buttons.info(false)" aria-label="Close" title="Close"><span aria-hidden="true">&times;</span></button></div>';
        var btn = '<br/><button type="button" role="button" class="btn btn-secondary" onclick="respite_crud.dt.buttons.info(false)">Close</button>';

        if (statusType == 'error') {
            respite_crud.dt.buttons.info(btnsm + '<i class="fas fa-exclamation-triangle"></i> ' + response.status + ' ' + response.statusText, response.responseText + btn);
        }
        else {
            respite_crud.dt.buttons.info('<i class="fas fa-check-circle"></i> ' + xhr.statusText, null, 750);
        }

        // refresh datatable:
        respite_crud.dt.ajax.reload();

        //alert('status: ' + statusType + '\n\nresponse: \n' + response['data'] + 
        //    '\n\nThe output div should have already been updated with the responseText.'); 
    }

    // Helper function for retrieving URL Parameters (Querystring)
    static getUrlParam(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    }

    // Returns datatable column object by name
    static getColumnByName(colName) {
        if (respite_crud.dt_Columns == undefined)
            return undefined;
        else {
            var col;

            for (var i = 0; i < respite_crud.dt_Columns.length && col == undefined; i++) {
                if (respite_crud.dt_Columns[i]['name'] == colName)
                    col = respite_crud.dt_Columns[i];
            }

            return col;
        }
    }

    // Detail Row Formatting
    /* this will print out all fields and sub-fields and their values */
    static renderDetailsRow(d) {
        if (d != undefined) {
            var rv = "";
            var col = {};
            for (var dKey in d) {
                col = respite_crud.getColumnByName(dKey);

                if (col == undefined)
                    col = "";
                else if (col['editor_data'] == undefined)
                    col = "";
                else
                    col = col['editor_data'];

                if (typeof d[dKey] === "object" || typeof d[dKey] === "array") {
                    // recursive:
                    rv += "<b>" + col['label'] + ':</b><div class="container-fluid">' + renderDetailsRow(d[dKey]) + '</div>';
                } else if (col != "") {
                    // simple string (stop condition):
                    rv += "<b>" + col['label'] + ":</b> " + respite_crud.renderAutomatic_ed(d[dKey], col, d) + "<br/> ";
                }
            }
            
            return rv;
        }
        else
            return 'Empty row';
    }

    // Init Options Function
    static setEditorOptions(options) {

        // init defaults
        if (respite_crud.respite_editor_options == undefined)
            respite_crud.respite_editor_options = {
                dt_Options: {
                    dt_Selector: '#mainGrid', // jquery selector for the <table> element to use for datatable
                    dt_AjaxGet: 'datatable_pilot_backend.asp?mode=datatable', // server-side source for datatable
                    dt_DetailRowRender: respite_crud.renderDetailsRow, // render function to display details of a single record
                    dt_RowReorder: {
                        form_selector: 'form[name=row_reorder_form]',
                        form_body_selector: '#row_reorder_body',
                        row_reorder_column: undefined,
                        pre_submit_callback: function () { return true },
                        response_success_callback: respite_crud.callbackPostResponseSimple,
                        response_error_callback: respite_crud.callbackPostResponseSimple
                    }
                },
                modal_Options: {
                    ajax_forms_selector: "form.ajax-form",
                    pre_submit_callback: respite_crud.callbackPreRequest,
                    response_success_callback: respite_crud.callbackPostResponse,
                    response_error_callback: respite_crud.callbackPostResponse,
                    modal_edit: {
                        modal_form_target: 'ajax_dataview.asp?viewId=undefined',
                        modal_selector: '#modal_edit',
                        modal_title_selector: '#modal_edit_title',
                        modal_body_selector: '#modal_edit_body',
                        form_selector: 'form[name=modal_edit_form]',
                        delete_button_selector: '#modal_btn_delete'
                    },
                    modal_delete: {
                        modal_form_target: 'ajax_dataview.asp?viewId=undefined',
                        modal_selector: '#modal_delete',
                        modal_title_selector: '#modal_delete_title',
                        modal_body_selector: '#modal_delete_body',
                        form_selector: 'form[name=modal_delete_form]'
                    },
                    modal_response: {
                        modal_selector: '#modal_response',
                        modal_title_selector: '#modal_response_title',
                        modal_body_selector: '#modal_response_body'
                    }
                }
            }

        // override options
        if (options != undefined)
            for (var key in options)
                respite_crud.respite_editor_options[key] = options[key];
    }

    // AJAX Form initialization
    /*
    options: {
            target:         string    // target element(s) to be updated with server response
            , beforeSubmit: function (formData, jqForm, options) {}          // pre-submit callback
            , success:      function (response, statusType, xhr, $form) {}          // post-submit callback
            , error:        function (xhr, statusType, $form)              // post-submit callback

            // other available options:
            // ,url:        string                                     // override for form's 'action' attribute
            // ,type:       string                                     // 'get' or 'post', override for form's 'method' attribute
             , dataType:    string                                     // 'xml', 'script', or 'json' (expected server response type)
            // ,clearForm:  boolean                                     // clear all form fields after successful submit
            // ,resetForm:  boolean                                     // reset the form after successful submit

            // $.ajax options can be used here too, for example:
            // ,timeout:    int
    }
    */
    static initAjaxForm(options, frmSelector) {
        // init defaults
        var setOptions = {
              target: respite_crud.respite_editor_options.modal_Options.modal_response.modal_body_selector    // target element(s) to be updated with server response
            , beforeSubmit: respite_crud.respite_editor_options.modal_Options.pre_submit_callback           // pre-submit callback
            , success: respite_crud.respite_editor_options.modal_Options.response_success_callback          // post-submit callback
            , error: respite_crud.respite_editor_options.modal_Options.response_error_callback              // post-submit callback

            // other available options:
            // ,url:       null                                     // override for form's 'action' attribute
            // ,type:      null                                     // 'get' or 'post', override for form's 'method' attribute
             , dataType: 'json'                                     // 'xml', 'script', or 'json' (expected server response type)
            // ,clearForm: true                                     // clear all form fields after successful submit
            // ,resetForm: true                                     // reset the form after successful submit

            // $.ajax options can be used here too, for example:
            // ,timeout:   3000
        }

        // override options
        if (options != undefined) 
            for (var key in options)
                setOptions[key] = options[key];
        
        var frmSelector = frmSelector || respite_crud.respite_editor_options.modal_Options.ajax_forms_selector;
        $(frmSelector).ajaxForm(setOptions);
    }
    // Utility Functions
    static focusFirstField(e, frm) {
        var frm = frm || $(respite_crud.respite_editor_options.modal_Options.modal_edit.form_selector);
        var firstInput = $(":input:not(input[type=button],input[type=submit],button):visible:first", frm);
        firstInput.focus();
    }
    static hideModal(modalSelector) {
        $(modalSelector).modal('hide')
    }
    static escapeHtml(v) {
        return (v != undefined ? $("<div></div>").text(v).html() : '');
    }

    static renderBoolean_ed(data, ed) {
        return (data == "true" || data == "1") ?
          '<i class="fas fa-check-circle text-success" title="' + data + '"></i>' :
          '<i class="fas fa-times-circle text-danger" title="' + data + '"></i>';
    }
    static renderBoolean(data, type, row, meta) {
        var oColumn = meta.settings.aoColumns[meta.col];
        return renderBoolean_ed(data, oColumn['editor_data']);
    }

    static renderLookup_ed(data, ed) {
        if (data != '' && data != undefined && ed != undefined && ed['options'] != undefined) {
            var opList = ed.options;

            for (var i = 0; i < opList.length; i++) {
                if (opList[i].value == data) {
                    return opList[i].label;
                }
            }
        }
        return data;
    }
    static renderLookup(data, type, row, meta) {
        return renderLookup_ed(data, oColumn['editor_data']);
    }

    static renderBitwiseLookup_ed(data, ed) {
        var rv = "";
        var nextOp = "";
        var glyph = $('<i></i>');

        if (data != '' && data != undefined && ed != undefined && ed['options'] != undefined) {

            var opList = ed.options;

            for (var i = 0; i < opList.length; i++) {

                if ((data & opList[i].value) > 0) {

                    nextOp = opList[i].label.trim();

                    if (opList[i]['glyph'] != undefined && opList[i]['glyph'] != '') {

                        glyph = $('<i class="' + opList[i]['glyph'] + '"></i>');
                        glyph.attr('data-toggle', 'tooltip');

                        if (opList[i]['tooltip'] != undefined && opList[i]['tooltip'] != '')
                            glyph.attr('title', opList[i]['tooltip'])
                        else if (opList[i]['label'] != undefined)
                            glyph.attr('title', opList[i]['label'])

                        nextOp = glyph.clone().wrap('<div>').parent().html();
                    } else if (rv.length > 0) {
                        rv += ",";
                    }

                    rv += ' ' + nextOp;
                }
            }
        }
        if (rv.length == 0) rv = data;
        return rv;
    }
    static renderBitwiseLookup(data, type, row, meta) {
        var oColumn = meta.settings.aoColumns[meta.col];
        return renderBitwiseLookup_ed(data, oColumn['editor_data']);
    }

    static renderCSVLookup_ed(data, ed) {
        var rv = "";
        if (data != '' && data != undefined && ed != undefined && ed['options'] != undefined) {

            var opList = ed.options;
            var dataList = data.split(",");

            for (var j = 0; j < dataList.length; j++) {
                for (var i = 0; i < opList.length; i++) {

                    if (opList[i].value == dataList[j]) {
                        if (rv.length > 0) rv += ", ";
                        rv += opList[i].label.trim();
                    }
                }
            }
        }
        if (rv.length == 0) rv = data;
        return rv;
    }
    static renderCSVLookup(data, type, row, meta) {
        var oColumn = meta.settings.aoColumns[meta.col];
        return renderCSVLookup_ed(data, oColumn['editor_data']);
    }

    static renderLink_ed(data, ed, id) {
        var rv = "";
        var attr = [];

        if (((id != null && id != undefined) || (data != '' && data != undefined)) && ed != undefined && ed["label"] != undefined) {
            rv = '<a href="' + respite_crud.escapeHtml(data) + '"';

            if (id != null && id != undefined)
                rv += ' id="' + id + '"';

            attr = ed["attributes"];
            for (var attrName in attr) {
                rv += ' ' + attrName + '="' + respite_crud.escapeHtml(attr[attrName]) + '"';
            }
            rv += '>' + ed["label"] + '</a>';
        }

        if (rv.length == 0) rv = data;
        return rv;
    }
    static renderLink(data, type, row, meta) {
        var ed = (meta != undefined && meta.settings.aoColumns[meta.col] != undefined ? meta.settings.aoColumns[meta.col]['editor_data'] : undefined);
        return respite_crud.renderLink_ed(data, ed, null);
    }

    static replaceRowPlaceholders(data, row, self) {
        var placeholderReplacements = respite_crud.placeholderReplacements;

        if (self != undefined && self != null)
            data = data.replace('{{this}}', self);

        if (row != undefined)
            for (var fieldKey in row) {
                data = data.replace('{{row[' + fieldKey + ']}}', row[fieldKey]);
            }

        for (var i = 0; i < placeholderReplacements.length; i++) {
            var placeholderKey = placeholderReplacements[i]['key'] || 'placeholder';

            for (var fieldKey in placeholderReplacements[i]['values']) {
                if (placeholderReplacements[i]['values'][fieldKey] != undefined && placeholderReplacements[i]['values'][fieldKey] != null)
                    data = data.replace('{{' + placeholderKey + '[' + fieldKey + ']}}', placeholderReplacements[i]['values'][fieldKey]);
            }
        }

        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName;

        for (var i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            data = data.replace('{{urlparam[' + sParameterName[0] + ']}}', sParameterName[1] === undefined ? true : sParameterName[1]);
        }

        return data;
    }

    static actionUrl(url, isNewWindow, params, row, self) {
        if (params != undefined) {
            if (url.indexOf('?') == -1) url += '?';
            url = url + $.param(params);
        }
        url = respite_crud.replaceRowPlaceholders(url, row, self);
        window.open(url, (isNewWindow ? '_blank' : '_self'));
    }

    static renderAutomatic_ed(data, ed, row) {
        var rv = "";
        if (data != undefined && data != '' && ed != undefined) {
            switch (ed["type"]) {
                case "boolean_switch":
                case "boolean_checkbox":
                case "boolean_radios":
                case "boolean_button":
                    rv = respite_crud.renderBoolean_ed(data, ed);
                    break;
                case "csv":
                case "csv_checkboxes":
                case "csv_switches":
                case "csv_buttons":
                    rv = respite_crud.renderCSVLookup_ed(data, ed);
                    break;
                case "select":
                case "select_buttons":
                case "select_switches":
                    rv = respite_crud.renderLookup_ed(data, ed);
                    break;
                case "bitwise_checkboxes":
                case "bitwise_switches":
                case "bitwise_buttons":
                    rv = respite_crud.renderBitwiseLookup_ed(data, ed);
                    break;
                case "link":
                    rv = respite_crud.renderLink_ed(data, ed);
                    break;
                default:
                    rv = data;
            }

            if (ed['wrap_link'] != undefined && ed["type"] != 'link' && row != undefined) {
                var newLink = $('<a></a>').attr('href', respite_crud.replaceRowPlaceholders(ed['wrap_link']['href'], row, data)).addClass(ed['wrap_link']['css'])
                .append(rv);

                rv = newLink[0].outerHTML;
            }
        }

        if (rv.length == 0) rv = data;
        return rv;
    }

    static renderAutomatic(data, type, row, meta) {
        var oColumn = meta.settings.aoColumns[meta.col];
        return respite_crud.renderAutomatic_ed(data, oColumn['editor_data'], row);
    }
            
    // This function runs after the data manipulation form is rendered
    static postRenderDMFormFields(e) {
        if (!respite_crud.DM_form_rendered) {
            $('.summernote textarea').each(function (i) {
                var currObj = $(this);
                currObj.summernote({
                    minHeight: currObj.attr('minHeight'),
                    maxHeight: currObj.attr('maxHeight'),
                    height: currObj.attr('height'),
                    width: currObj.attr('width'),
                    placeholder: currObj.attr('placeholder'),
                    focus: true,
                    tabsize: 2,
                    dialogsInBody: true,
                    codemirror: { // codemirror options
                        theme: 'monokai'
                    }
                });
            });

            //respite_crud.DM_form_rendered = true;
        }
        respite_crud.focusFirstField(e);
    }
    // Data Manipulation Modals
    static showDMModal(r, mode) {
        respite_crud.showDMModal_dynamic(r, mode);
        return;
        var modal_options = respite_crud.respite_editor_options.modal_Options.modal_edit;

        // save to static row object for the Deletion modal to access
        if (r == undefined || r == null)
            respite_crud.row = respite_crud.initDefaultRow();
        else
            respite_crud.row = r;

        // init modal title and deletion button
        if (mode == "edit") {
            $(modal_options.modal_title_selector).text("Edit Item RowID: " + respite_crud.row.DT_RowId);   // localization.modal_edit_title
            $(modal_options.delete_button_selector).show();
        }
        else {
            $(modal_options.modal_title_selector).text("Add Item");                         // localization.modal_add_title
            $(modal_options.delete_button_selector).hide();
        }

        if (!respite_crud.DM_form_rendered) {
            // first render of modal form fields
            $(modal_options.modal_body_selector).html(respite_crud.renderDMFormFields(respite_crud.row));
            $(modal_options.modal_selector).on('shown.bs.modal', respite_crud.postRenderDMFormFields);
        }
        else {
            // re-fill existing modal form fields
            respite_crud.fillDMFormFields(respite_crud.row, modal_options.form_selector);
        }

        // init form global fields
        $('input[name=DT_RowId]', $(modal_options.form_selector)).val(respite_crud.row.DT_RowId);   // input_init_values: [ { input_name: value } ]
        $('input[name=mode]', $(modal_options.form_selector)).val(mode);
        $(modal_options.modal_selector).modal({ show: true, keyboard: true, focus: true });
    }
    static showDelete(r) {
        respite_crud.showDelete_dynamic(r);
        return;

        var modal_options = respite_crud.respite_editor_options.modal_Options.modal_delete;

        $(modal_options.modal_body_selector).html(respite_crud.respite_editor_options.dt_Options.dt_DetailRowRender(r)); // render modal with row details
        $('input[name=DT_RowId]', $(modal_options.form_selector)).val(r.DT_RowId); // input_init_values: [ { input_name: value } ]
        $('input[name=mode]', $(modal_options.form_selector)).val("delete");
        $(modal_options.modal_selector).modal({ show: true, keyboard: true, focus: true });
    }
    static showDeleteMultiple(e, dt, node, config) {
        respite_crud.showDeleteMultiple_dynamic(e, dt, node, config);
        return;

        var modal_options = respite_crud.respite_editor_options.modal_Options.modal_delete;

        var r = dt.rows({ selected: true }).data();
        var rowIds = "";
        var content = "Deleting " + r.length + " row(s):";

        for (var i = 0; i < r.length; i++) {
            if (rowIds.length > 0) rowIds += ", ";
            rowIds += r[i].DT_RowId;
            content += "<hr/> " + respite_crud.respite_editor_options.dt_Options.dt_DetailRowRender(r[i]);                          // concatenate_row_details
        }

        $(modal_options.modal_body_selector).html(content);                                      // modal_body_selector
        $('input[name=DT_RowId]', $(modal_options.form_selector)).val(rowIds);         // modal_form_name, input_init_values: [ { input_name: value } ]
        $('input[name=mode]', $(modal_options.form_selector)).val("delete_multiple");  // modal_form_name
        $(modal_options.modal_selector).modal({ show: true, keyboard: true, focus: true });      // modal_to_show, modal_options = {}
    }
    // Data Manipulation Modals (Dynamic Modal)
    static showDMModal_dynamic(r, mode) {
        var modal_options = respite_crud.respite_editor_options.modal_Options.modal_edit;
        var form_id = 'form_modal_modify_' + mode;
        var title = "";
        var buttons = [{ Value: "Cancel", Css: "btn-default pull-left float-left" }, { Value: "<i class='fas fa-save'></i> Save Changes", Css: "btn-success", Callback: function (e) { $('#' + form_id).submit(); } }]; // localization['Cancel']
        
        // save to static row object for the Deletion modal to access
        if (r == undefined || r == null)
            respite_crud.row = respite_crud.initDefaultRow();
        else
            respite_crud.row = r;

        // init modal title and deletion button
        if (mode == "edit") {
            title = "Edit Item RowID: " + respite_crud.row.DT_RowId;   // localization.modal_edit_title
            buttons.push({ Value: "<i class='fas fa-trash-alt'></i> Delete", Css: "btn-danger pull-left float-left", Callback: function (e) { respite_crud.showDelete_dynamic(respite_crud.row) } });
        }
        else {
            title = "Add Item";                         // localization.modal_add_title
        }
        var body = $('<form class="ajax-form" name="modal_edit_form" action="ajax_dataview.asp?ViewID=undefined" method="post" id="' + form_id + '"></form>')
                .attr('action', modal_options.modal_form_target)
                .append(respite_crud.renderDMFormFields(respite_crud.row));

        // init form global fields
        body.append($('<input type="hidden" name="postback" value="true" />'))
        .append($('<input type="hidden" name="DT_RowId" value="" />').val(respite_crud.row.DT_RowId))
        .append($('<input type="hidden" name="mode" value="add" />').val(mode))
        .append($('<input type="submit" autofocus style="position:absolute; left:-9999px; width:0px; height:0px;" />'));

        new BstrapModal(
            title, body.clone().wrap('<div>').parent().html(), buttons,
            function (e, modalId) {
                $('.summernote textarea').each(function (i) {
                    var currObj = $(this);
                    currObj.summernote({
                        minHeight: currObj.attr('minHeight'),
                        maxHeight: currObj.attr('maxHeight'),
                        height: currObj.attr('height'),
                        width: currObj.attr('width'),
                        placeholder: currObj.attr('placeholder'),
                        focus: true,
                        tabsize: 2,
                        dialogsInBody: true,
                        codemirror: { // codemirror options
                            theme: 'monokai'
                        }
                    });
                });
                //console.log($(this));
                $('#' + form_id).attr('form-modal', '#' + modalId);

                // init ajax form
                $('#' + form_id).ajaxForm({
                    target: respite_crud.respite_editor_options.modal_Options.modal_response.modal_body_selector    // target element(s) to be updated with server response
                    , beforeSubmit: respite_crud.respite_editor_options.modal_Options.pre_submit_callback           // pre-submit callback
                    , success: respite_crud.respite_editor_options.modal_Options.response_success_callback          // post-submit callback
                    , error: respite_crud.respite_editor_options.modal_Options.response_error_callback              // post-submit callback
                    , dataType: 'json'                                     // 'xml', 'script', or 'json' (expected server response type)
                });

                respite_crud.focusFirstField(e, $('#' + form_id));
            }
            ).Show();
    }
    static showDelete_dynamic(r) {
        var modal_options = respite_crud.respite_editor_options.modal_Options.modal_delete;
        var form_id = 'form_modal_delete';
        var title = "Are you sure you want to delete?";
        var buttons = [{ Value: "Cancel", Css: "btn-default pull-left float-left" }, { Value: "<i class='fas fa-trash-alt'></i> Delete", Css: "btn-danger", Callback: function (e) { $('#' + form_id).submit(); } }]; // localization['Cancel']
        var body = $('<form class="ajax-form" name="modal_delete_form" action="ajax_dataview.asp?ViewID=undefined" method="post" id="' + form_id + '"></form>')
                .attr('action', modal_options.modal_form_target)
                .append(respite_crud.respite_editor_options.dt_Options.dt_DetailRowRender(r)); // render modal with row details

        body.append($('<input type="hidden" name="postback" value="true" />'))
        .append($('<input type="hidden" name="DT_RowId" value="" />').val(r.DT_RowId))
        .append($('<input type="hidden" name="mode" value="delete" />').val("delete"));

        new BstrapModal(
            title, body.clone().wrap('<div>').parent().html(), buttons,
            function (e, modalId) {
                $('#' + form_id).attr('form-modal', '#' + modalId);

                // init ajax form
                $('#' + form_id).ajaxForm({
                    target: respite_crud.respite_editor_options.modal_Options.modal_response.modal_body_selector    // target element(s) to be updated with server response
                    , beforeSubmit: respite_crud.respite_editor_options.modal_Options.pre_submit_callback           // pre-submit callback
                    , success: respite_crud.respite_editor_options.modal_Options.response_success_callback          // post-submit callback
                    , error: respite_crud.respite_editor_options.modal_Options.response_error_callback              // post-submit callback
                    , dataType: 'json'                                     // 'xml', 'script', or 'json' (expected server response type)
                });
            }).Show(true);
    }
    static showDeleteMultiple_dynamic(e, dt, node, config) {
        var modal_options = respite_crud.respite_editor_options.modal_Options.modal_delete;
        var form_id = 'form_modal_delete_multi';
        var title = "Are you sure you want to delete?";
        var buttons = [{ Value: "Cancel", Css: "btn-default pull-left float-left" }, { Value: "<i class='fas fa-trash-alt'></i> Delete", Css: "btn-danger", Callback: function (e) { $('#' + form_id).submit(); } }]; // localization['Cancel']
        
        var r = dt.rows({ selected: true }).data();
        var rowIds = "";
        var content = "You're about to delete " + r.length + " row(s):";

        for (var i = 0; i < r.length; i++) {
            if (rowIds.length > 0) rowIds += ", ";
            rowIds += r[i].DT_RowId;
            content += "<hr/> " + respite_crud.respite_editor_options.dt_Options.dt_DetailRowRender(r[i]);
        }
        var body = $('<form class="ajax-form" name="modal_delete_form_multi" action="ajax_dataview.asp?ViewID=undefined" method="post" id="' + form_id + '"></form>')
                .attr('action', modal_options.modal_form_target)
                .append($('<div></div>').html(content)); // render modal with row details

        body.append($('<input type="hidden" name="postback" value="true" />'))
        .append($('<input type="hidden" name="DT_RowId" value="" />').val(rowIds))
        .append($('<input type="hidden" name="mode" value="delete" />').val("delete_multiple"));

        new BstrapModal(
            title, body.clone().wrap('<div>').parent().html(), buttons,
            function (e, modalId) {
                $('#' + form_id).attr('form-modal', '#' + modalId);

                // init ajax form
                $('#' + form_id).ajaxForm({
                    target: respite_crud.respite_editor_options.modal_Options.modal_response.modal_body_selector    // target element(s) to be updated with server response
                    , beforeSubmit: respite_crud.respite_editor_options.modal_Options.pre_submit_callback           // pre-submit callback
                    , success: respite_crud.respite_editor_options.modal_Options.response_success_callback          // post-submit callback
                    , error: respite_crud.respite_editor_options.modal_Options.response_error_callback              // post-submit callback
                    , dataType: 'json'                                     // 'xml', 'script', or 'json' (expected server response type)
                });
            }).Show(true);
    }

    // Init Default Row (when adding)
    static initDefaultRow() {
        var r = {}
        var ed = {}
        var cn = {}

        for (var i = 0; i < respite_crud.dt.columns()[0].length; i++) {
            ed = respite_crud.dt.column(i).editor_data();
            cn = respite_crud.dt.column(i).dataSrc();

            if (ed != undefined && cn != undefined) {
                r[cn] = ed["default_value"];
            } else {
                r[cn] = null;
            }
        }

        return r;
    }

    // Data Manipulation Modal Formatting (rendering form fields)
    static renderDMFormFields(d, columns, input_prefix) {
        var content = "";
        var closing_string = "";
        var element = "";
        var ed = {}
        var cn = "";
        var id = "";
        var attr = [];
        var dValues = [];
        var currOpt = $('<option></option>');
        var bFoundEmptyOpt = false;
        var prevOptGroup = undefined;
        var currOptGroup = $('<optgroup></optgroup>');
        var arrColumns = columns;
        var inputPrefix = input_prefix || "field_";

        if (arrColumns == undefined) {
            arrColumns = [];
            for (var i = 0; i < respite_crud.dt.columns()[0].length; i++) {
                arrColumns.push({ "name": respite_crud.dt.column(i).name(), "data": respite_crud.dt.column(i).dataSrc(), "editor_data": respite_crud.dt.column(i).editor_data() })
            }
        }

        //console.log(d);
        for (var i = 0; i < arrColumns.length; i++) {
            ed = arrColumns[i].editor_data;
            id = arrColumns[i].name; // inputPrefix + i
            cn = arrColumns[i].data;
            //console.log("column " + i + " (" + cn + "): " + d[cn]);

            if (ed != undefined && !ed["hidden"]) {
                element = $('<label>ERROR Column ' + i + '</label>');
                closing_string = "";
                content += '<div class="form-group' + (ed['type'] == "rte" ? ' summernote' : '') + '" data-toggle="tooltip" title="' + respite_crud.escapeHtml(ed['tooltip']) + '">';
                content += '<label for="' + id + '" class="control-label col-sm-3 col-md-4 col-lg-4">';

                if (ed["help"] != undefined && ed["help"] != "") {
                    content += '<div class="ml-auto float-right"><a class="btn btn-link text-info" data-toggle="collapse" data-target="#help_' + id + '" aria-expanded="false" aria-controls="help_' + id + '" title="Help"><i class="fas fa-question-circle"></i></a></div>';
                }

                content += respite_crud.escapeHtml(ed['label']) + '</label><div class="input-group col-sm-9 col-md-8 col-lg-8">';

                // open html element tag
                switch (ed['type']) {
                    case "money":
                    case "decimal":
                    case "integer":
                    case "numeric":
                    case "number":
                        element = $('<input tabindex="' + i + '" class="form-control form-control-sm" type="number" id="' + id + '" name="' + cn + '" step="1" />');
                        element.attr('value', d[cn]);
                        // TODO: add format validation based on type (using the "pattern" attribute with regex: https://www.w3schools.com/tags/att_input_pattern.asp )
                        break;
                    case "select":
                    case "select_buttons":
                    case "select_switches":
                    case "csv":
                    case "csv_checkboxes":
                    case "csv_switches":
                    case "csv_buttons":
                        element = $('<select tabindex="' + i + '" class="form-control form-control-sm" id="' + id + '" name="' + cn + '"></select>');
                        if (ed['type'] == "csv")
                            element.attr('multiple', 'multiple');
                        break;
                    case "bitwise":
                    case "bitwise_checkboxes":
                    case "bitwise_switches":
                    case "bitwise_buttons":
                        element = $('<div id="' + id + '"></div>');
                        break;
                    case "rte":
                    case "textarea":
                        element = $('<textarea tabindex="' + i + '" class="form-control form-control-sm" id="' + id + '" name="' + cn + '"></textarea>');
                        element.text(d[cn]);
                        break;
                    case "boolean":
                    case "boolean_switch":
                    case "boolean_checkbox":
                    case "boolean_radios":
                    case "boolean_button":
                        // using bootswatch switch custom control
                        content += '<div class="custom-control custom-switch">';
                        element = $('<input tabindex="' + i + '" id="' + id + '" type="checkbox" value="true" class="custom-control-input" name="' + cn + '"/>');
                        if (d[cn] == "true" || d[cn] == true)
                            element.attr('checked', 'checked');
                        closing_string = '<label for="' + id + '" class="custom-control-label"></label></div>';
                        break;
                    case "password":
                        element = $('<input tabindex="' + i + '" class="form-control form-control-sm" type="password" id="' + id + '" name="' + cn + '" value="" />');
                        break;
                    case "time":
                        element = $('<input tabindex="' + i + '" class="form-control form-control-sm" type="time" id="' + id + '" name="' + cn + '" step="1" maxlength="8" />');
                        element.attr('value', d[cn].substr(0, 8));
                        break;
                    case "date":
                        element = $('<input tabindex="' + i + '" class="form-control form-control-sm" type="date" id="' + id + '" name="' + cn + '" step="1" maxlength="10" />');
                        element.attr('value', d[cn].substr(0, 10));
                        break;
                    case "datetime":
                        element = $('<input tabindex="' + i + '" class="form-control form-control-sm" type="datetime-local" id="' + id + '" name="' + cn + '" step="1" maxlength="20" />');
                        element.attr('value', d[cn].substr(0, 20));
                        break;
                    case "link":
                        element = $(respite_crud.renderLink_ed(d[cn], ed, id));
                        break;
                    case "phone":
                    case "email":
                    case "text":
                    default:
                        element = $('<input tabindex="' + i + '" class="form-control form-control-sm" type="text" id="' + id + '" name="' + cn + '" />');
                        element.attr('type', ed['type']);
                        element.attr('value', d[cn]);
                        // TODO: more field types: formula, image (upload), document (upload), bitwise
                        // some of these field types would also require additional render functions
                        // additionally, a few custom types based on https://bootswatch.com : csv_checkbox, csv_buttons, select_radio, select_buttons
                        // TODO: additional column options (some of these are relevant to the grid table only): glyph, help, tooltip, cssView, cssCell, cssColumnHeader
                        // TODO: preset column attributes per field type: tooltip, placeholder, min, max, maxlength, format (pattern), required, height, width, read-only, cssEdit
                }

                // append any attributes
                if (ed['attributes'] != undefined && ed['type'] != "link") {
                    attr = ed['attributes'];
                    for (var attrName in attr) {
                        if (ed['type'] != "boolean" || attrName != "required")
                            element.attr(attrName, attr[attrName]);
                    }
                }

                // fill with any content inside element tag
                switch (ed['type']) {
                    case "select":
                    case "select_buttons":
                    case "select_switches":
                    case "csv":
                    case "csv_checkboxes":
                    case "csv_switches":
                    case "csv_buttons":
                        dValues = [];
                        currOpt = $('<option></option>');
                        if (ed['options'] != undefined) {

                            if (d[cn] != undefined && ed['type'] == "csv")
                                dValues = d[cn].split(",");
                            else if (d[cn] != undefined) // if not csv, init array of single value
                            {
                                dValues = [d[cn]];

                                // generate optional empty value if such was not provided in options already
                                if (ed['attributes']['required'] != 'true') {
                                    bFoundEmptyOpt = false;

                                    for (var j = 0; j < ed['options'].length; j++) {
                                        if (ed['options'][j]['value'] == '')
                                            bFoundEmptyOpt = true;
                                    }

                                    if (!bFoundEmptyOpt) {
                                        currOpt = $('<option></option>');
                                        if (d[cn] == '')
                                            currOpt.attr('selected', 'selected');
                                        element.append(currOpt.clone());
                                    }
                                }
                            }

                            // trim comma separated values to remove whitespaces
                            for (var k = 0; k < dValues.length; k++) {
                                dValues[k] = dValues[k].trim();
                            }

                            prevOptGroup = undefined;
                            currOptGroup = $('<optgroup></optgroup>');

                            for (var j = 0; j < ed['options'].length; j++) {
                                if (prevOptGroup != ed['options'][j]['group']) {
                                    if (prevOptGroup != undefined) {
                                        element.append(currOptGroup.clone());
                                    }
                                    if (ed['options'][j]['group'] != '') {
                                        currOptGroup = $('<optgroup></optgroup>');
                                        currOptGroup.attr('label', ed['options'][j]['group']);
                                    }
                                    prevOptGroup = (ed['options'][j]['group'] == '' ? undefined : ed['options'][j]['group']);
                                }
                                currOpt = $('<option></option>');
                                currOpt.attr('value', ed['options'][j]['value']);

                                for (var k = 0; k < dValues.length; k++) {
                                    if (dValues[k].trim() == ed['options'][j]['value'].trim())
                                        currOpt.attr('selected', 'selected');
                                }

                                currOpt.text(ed['options'][j]['label']);
                                if (prevOptGroup != undefined)
                                    currOptGroup.append(currOpt);
                                else {
                                    element.append(currOpt.clone());
                                }
                            }
                            if (prevOptGroup != undefined && prevOptGroup != '') {
                                element.append(currOptGroup.clone());
                            }
                        }
                        break;
                    case "bitwise":
                    case "bitwise_checkboxes":
                    case "bitwise_switches":
                    case "bitwise_buttons":
                        var currDiv = $('<div class="checkbox custom-control custom-checkbox"></div>');
                        var currInput = $('<input type="checkbox" class="custom-control-input" name="' + cn + '"/>');
                        var currLabel = $('<label class="custom-control-label"></label>');
                        var dValues = 0;

                        if (d[cn] != undefined)
                            dValues = d[cn];

                        for (var j = 0; j < ed['options'].length; j++) {

                            currDiv = $('<div class="checkbox custom-control custom-checkbox"></div>');
                            currInput = $('<input type="checkbox" class="custom-control-input" id="' + id + '_' + j + '" name="' + cn + '"/>');
                            currInput.attr('value', ed['options'][j]['value']);

                            if ((dValues & ed['options'][j]['value']) > 0)
                                currInput.attr('checked', 'checked');

                            currLabel = $('<label></label>');

                            if (ed['options'][j]['tooltip'] != undefined && ed['options'][j]['tooltip'] != '') {
                                currLabel.attr('data-toggle', 'tooltip');
                                currLabel.attr('title', ed['options'][j]['tooltip']);
                            }

                            currDiv
                                .append(currLabel.clone()
                                    .append(currInput.clone())
                                    //.append($('<label class="custom-control-label" for="' + id + '_' + j + '"></label>')) // reserved for bootstrap 4
                                    .append($('<i class="' + ed['options'][j]['glyph'] + '"></i>'))
                                    .append($('<span></span>').text(' ' + ed['options'][j]['label']))
                                    );

                            element.append(currDiv.clone());
                        }
                        break;
                        // TODO: more field types
                    default:
                }
                // close element
                content += element.clone().wrap('<div>').parent().html() + closing_string + '</div></div>';
                if (ed["help"] != undefined && ed["help"] != "") {
                    content += '<div id="help_' + id + '" class="collapse bg-info"><div class="ml-auto float-right"><button type="button" role="button" class="btn btn-secondary btn-sm" data-toggle="collapse" data-target="#help_' + id + '" aria-expanded="false" aria-controls="help_' + id + '" aria-label="Close" title="Close"><span aria-hidden="true">&times;</span></button></div>' + ed["help"] + '</div>';
                }
            }
        }

        return content;
    }

    // Fill Existing Data Manipulation Form
    static fillDMFormFields(d, form_selector, columns, input_prefix) {
        var ed = {}
        var cn = "";
        var id = "";
        var dValues = [];
        var arrColumns = columns;
        var inputPrefix = input_prefix || "field_";

        if (arrColumns == undefined) {
            arrColumns = [];
            for (var i = 0; i < respite_crud.dt.columns()[0].length; i++) {
                arrColumns.push({ "data": respite_crud.dt.column(i).dataSrc(), "name": respite_crud.dt.column(i).name(), "editor_data": respite_crud.dt.column(i).editor_data() })
            }
        }

        for (var i = 0; i < arrColumns.length; i++) {
            ed = arrColumns[i].editor_data;
            cn = arrColumns[i].data;
            id = arrColumns[i].name; // inputPrefix + i

            if (ed != undefined) {
                switch (ed['type']) {
                    case "image":
                        //$('#' + id + '_src').attr('src', respite_crud.escapeHtml(d[cn]));
                        //$('#' + id, $(form_selector)).val(respite_crud.escapeHtml(d[cn]));
                        //break;
                    case "document":
                    case "file":
                        // upload inputs must always be set to empty string only
                        $('#' + id).val("");
                        break;
                    case "csv":
                    case "csv_checkboxes":
                    case "csv_switches":
                    case "csv_buttons":
                        // de-select all currently selected options
                        $('#' + id).val('');
                        $('#' + id + ' option').attr('selected', false);

                        // re-select based on row data
                        if (d[cn] != undefined && ed['options'] != undefined) {
                            dValues = d[cn].split(",");

                            for (var j = 0; j < dValues.length; j++)
                                dValues[j] = dValues[j].trim();

                            $('#' + id).val(dValues);
                        }
                        break;
                    case "bitwise":
                    case "bitwise_checkboxes":
                    case "bitwise_switches":
                    case "bitwise_buttons":
                        // de-select all currently selected options
                        $('#' + id + ' div label input').attr('checked', false);

                        // re-select based on row data
                        if (d[cn] != undefined) {
                            dValues = d[cn];

                            for (var j = 0; j < ed['options'].length; j++) {
                                if ((dValues & ed['options'][j]['value']) > 0)
                                    $('#' + id + '_' + j).attr('checked', 'checked');
                            }
                        }
                    case "link":
                        $('#' + id).attr('href', d[cn]);
                        break;
                    case "rte":
                        $('#' + id).summernote('code', d[cn]);
                        break;
                    case "boolean":
                    case "boolean_switch":
                    case "boolean_checkbox":
                    case "boolean_radios":
                    case "boolean_button":
                        $('#' + id, $(form_selector)).attr('checked', (d[cn] == "true" || d[cn] == true));
                        break;
                    default:
                        $('#' + id, $(form_selector)).val(respite_crud.escapeHtml(d[cn]));
                }
            }
            else
                $('#' + id, $(form_selector)).val(respite_crud.escapeHtml(d[cn]));
        }
    }

    static getNextActionButtonIndex() {
        return (respite_crud.dt_InlineActionButtons == undefined ? 0 : respite_crud.dt_InlineActionButtons.length);
    }

    static renderRowReorderCell(data, type, row, meta) {
        return '<i class="fas fa-grip-vertical text-muted" data-toggle="tooltip" data-placement="right" title="Drag to reorder"></i>';
    }

    static renderInlineActionButtons(data, type, row, meta) {
        var rv = $('<span style="white-space: nowrap"></span>');
        var a = $('<a></a>');

        for (var i = 0; respite_crud.dt_InlineActionButtons != undefined && i < respite_crud.dt_InlineActionButtons['length']; i++) {

            a = $('<a href="' + respite_crud.dt_InlineActionButtons[i]['href'] + '" class="' + respite_crud.dt_InlineActionButtons[i]['class'] + '" role="button" data-toggle="tooltip" data-placement="bottom" title="' + respite_crud.dt_InlineActionButtons[i]['title'] + '"></a>');

            if (respite_crud.dt_InlineActionButtons[i]['glyph'] != "" && respite_crud.dt_InlineActionButtons[i]['glyph'] != undefined)
                a.append($('<i class="' + respite_crud.dt_InlineActionButtons[i]['glyph'] + '"></i>'));

            if (respite_crud.dt_InlineActionButtons[i]['label'] != "" && respite_crud.dt_InlineActionButtons[i]['label'] != undefined)
                a.append($(' ' + respite_crud.dt_InlineActionButtons[i]['label']));

            rv.append($('<span>&nbsp;</span>')).append(a.clone());
        }

        return rv.clone().wrap('<div>').parent().html();
    }

        /*
        objButton: {
            href: string,
            class: string,
            title: string,
            glyph: string,
            label: string
        },
        onClickFunction: function (e, tr, r) {}
        */
    static addInlineActionButton(objButton, onClickFunction) {
        if (respite_crud.dt_InlineActionButtons == undefined) {
            respite_crud.dt_InlineActionButtons = [];
        }

        if (onClickFunction != undefined) {
            var btnClassName = "respite_btn_" + respite_crud.getNextActionButtonIndex();
            $('tbody', $(respite_crud.respite_editor_options.dt_Options.dt_Selector)).on('click', 'tr td a.' + btnClassName, function (e) {     // datatable_selector
                var tr = $(this).closest('tr');
                var r = respite_crud.dt.row(tr).data();
                onClickFunction(e, tr, r);
            });

            if (objButton['class'] != undefined)
                objButton['class'] += " " + btnClassName;
            else
                objButton['class'] = btnClassName;

            //console.log("Added custom inline action button ");
            //console.log(onClickFunction);
        }

        respite_crud.dt_InlineActionButtons.push(objButton);

        // return self to allow chaining
        return respite_crud;
    }

        //// DETAIL ROW Initialization ////
    static addDetailsButton(render_function) {
        //if (respite_crud.dt == undefined)
        //    throw "Error: addDetailsButton cannot be used before the datatable is initialized!";

        if (render_function != undefined)
            respite_crud.respite_editor_options.dt_Options.dt_DetailRowRender = render_function;

        // Array to track the ids of the details displayed rows
        respite_crud.detailRows = [];

        $('tbody', $(respite_crud.respite_editor_options.dt_Options.dt_Selector)).on('click', 'tr td a.details-control', function (e) {     // datatable_selector
            var tr = $(this).closest('tr');
            var row = respite_crud.dt.row(tr);                                                   // dt object
            var idx = $.inArray(tr.attr('id'), respite_crud.detailRows);
            var glyph = $('i', $(this));

            if (row.child.isShown()) {
                tr.removeClass('details');
                glyph.removeClass('fa-minus-circle');
                glyph.addClass('fa-plus-circle');
                $(this).removeClass('text-danger');
                $(this).addClass('text-success');
                row.child.hide();

                // Remove from the 'open' array
                respite_crud.detailRows.splice(idx, 1);
            }
            else {
                tr.addClass('details');
                glyph.removeClass('fa-plus-circle');
                glyph.addClass('fa-minus-circle');
                $(this).removeClass('text-success');
                $(this).addClass('text-danger');
                row.child(respite_crud.respite_editor_options.dt_Options.dt_DetailRowRender(row.data())).show();

                // Add to the 'open' array
                if (idx === -1) {
                    respite_crud.detailRows.push(tr.attr('id'));
                }
            }
        });

        respite_crud.isDetailRowsAdded = true;

        // return self to allow chaining
        return respite_crud.addInlineActionButton(
            {
                "href": "javascript:void(0)",
                "class": "btn-link text-success details-control",
                "title": "Details",
                "glyph": "fas fa-plus-circle",
                "label": ""
            });
    }

        //// INLINE Data Manipulation Buttons Initialization ////
    static addEditButton(title, label, glyph, customClass) {
        var btnClassName = "respite_btn_" + respite_crud.getNextActionButtonIndex();
        respite_crud.edit_button_selector = btnClassName;

        $('tbody', $(respite_crud.respite_editor_options.dt_Options.dt_Selector)).on('click', 'tr td a.' + btnClassName, function (e) {     // datatable_selector
            var tr = $(this).closest('tr');
            var r = respite_crud.dt.row(tr).data();                                             // dt object
            respite_crud.showDMModal(r, "edit");
        });

        return respite_crud.addInlineActionButton(
            {
                "href": "javascript:void(0)",
                "class": (customClass == undefined || customClass == null ? "btn btn-success btn-sm" : customClass) + " " + btnClassName,
                "title": (title == undefined || title == null ? "Edit" : title),
                "glyph": (glyph == undefined || glyph == null ? "fas fa-edit" : glyph),
                "label": (label == undefined || label == null ? "" : label)
            });
    }
    static addCloneButton(title, label, glyph, customClass) {
        var btnClassName = "respite_btn_" + respite_crud.getNextActionButtonIndex();

        $('tbody', $(respite_crud.respite_editor_options.dt_Options.dt_Selector)).on('click', 'tr td a.' + btnClassName, function (e) {
            var tr = $(this).closest('tr');
            var r = respite_crud.dt.row(tr).data();
            respite_crud.showDMModal(r, "add");
        });

        return respite_crud.addInlineActionButton(
            {
                "href": "javascript:void(0)",
                "class": (customClass == undefined || customClass == null ? "btn btn-info btn-sm" : customClass) + " " + btnClassName,
                "title": (title == undefined || title == null ? "Clone" : title),
                "glyph": (glyph == undefined || glyph == null ? "fas fa-copy" : glyph),
                "label": (label == undefined || label == null ? "" : label)
            });
    }
    static addDeleteButton(title, label, glyph, customClass) {
        var btnClassName = "respite_btn_" + respite_crud.getNextActionButtonIndex();
        respite_crud.delete_button_selector = btnClassName;

        $('tbody', $(respite_crud.respite_editor_options.dt_Options.dt_Selector)).on('click', 'tr td a.' + btnClassName, function (e) {    // datatable_selector
            var tr = $(this).closest('tr');
            var r = respite_crud.dt.row(tr).data();                                              // dt object
            respite_crud.showDelete(r);
        });

        return respite_crud.addInlineActionButton(
            {
                "href": "javascript:void(0)",
                "class": (customClass == undefined || customClass == null ? "btn btn-danger btn-sm" : customClass) + " " + btnClassName,
                "title": (title == undefined || title == null ? "Delete" : title),
                "glyph": (glyph == undefined || glyph == null ? "far fa-trash-alt" : glyph),
                "label": (label == undefined || label == null ? "" : label)
            });
    }

    static addToolbarActionButton(objButton) {
        if (respite_crud.dt != undefined) {
            throw "Error: Toolbar Action Buttons cannot be added after datatable is already initialized.";
        }

        if (respite_crud.dt_Buttons == undefined) {
            respite_crud.dt_Buttons = [];
        }

        respite_crud.dt_Buttons.push(objButton);

        // if datatable is already initialized, add using api
        if (respite_crud.dt != undefined) {
            respite_crud.dt.button().add(respite_crud.dt_Buttons.length, objButton);
        }

        // return self to allow chaining
        return respite_crud;
    }

    static addAddButton(title, glyph, customClass) {
        return respite_crud.addToolbarActionButton(
            {
                text: (glyph == undefined || glyph == null ? '<i class="fas fa-plus"></i>' : '<i class="' + glyph + '"></i> ') + (title == undefined || title == null ? "Add" : title),
                className: (customClass == undefined || customClass == null ? "btn btn-success btn-sm" : customClass),
                action: function (e, dt, node, config) {
                    respite_crud.showDMModal(null, "add");
                }
            });
    }
    static addRefreshButton(title, glyph, customClass) {
        return respite_crud.addToolbarActionButton(
            {
                text: (glyph == undefined || glyph == null ? '<i class="fas fa-sync-alt"></i> ' : '<i class="' + glyph + '"></i> ') + (title == undefined || title == null ? "Refresh" : title),
                className: (customClass == undefined || customClass == null ? "btn btn-primary btn-sm" : customClass),
                action: function (e, dt, node, config) {
                    dt.ajax.reload();
                }
            });
    }
    static addSelectAllButton(title, glyph, customClass) {
        return respite_crud.addToolbarActionButton(
            {
                text: (glyph == undefined || glyph == null ? '<i class="far fa-check-circle"></i> ' : '<i class="' + glyph + '"></i> ') + (title == undefined || title == null ? 'Select All' : title),
                className: (customClass == undefined || customClass == null ? "btn btn-default btn-sm" : customClass),
                action: function (e, dt, node, config) {
                    dt.rows().select();
                }
            });
    }
    static addDeSelectAllButton(title, glyph, customClass) {
        return respite_crud.addToolbarActionButton(
            {
                text: (glyph == undefined || glyph == null ? '<i class="far fa-circle"></i> ' : '<i class="' + glyph + '"></i> ') + (title == undefined || title == null ? 'De-Select All' : title),
                className: (customClass == undefined || customClass == null ? "btn btn-default btn-sm" : customClass),
                action: function (e, dt, node, config) {
                    dt.rows().deselect();
                }
            });
    }
    static addDeleteSelectedButton(title, glyph, customClass) {
        return respite_crud.addToolbarActionButton(
            {
                text: (glyph == undefined || glyph == null ? '<i class="fas fa-trash-alt"></i> ' : '<i class="' + glyph + '"></i> ') + (title == undefined || title == null ? 'Delete Selected' : title),
                className: (customClass == undefined || customClass == null ? "btn btn-danger btn-sm" : customClass),
                action: respite_crud.showDeleteMultiple
            });
    }
    static addExportButton(arrButtons, title, glyph, customClass) {
        // if no specific buttons specified, add all of them by default
        if (arrButtons == undefined)
            arrButtons = [
                    {
                        extend: 'copy',
                        exportOptions: {
                            columns: '.dt-exportable'
                        }
                    },
                    {
                        extend: 'excel',
                        exportOptions: {
                            columns: '.dt-exportable'
                        }
                    },
                    {
                        extend: 'csv',
                        exportOptions: {
                            columns: '.dt-exportable'
                        }
                    },
                    {
                        extend: 'pdf',
                        exportOptions: {
                            columns: '.dt-exportable'
                        }
                    },
                    {
                        extend: 'print',
                        exportOptions: {
                            columns: '.dt-exportable'
                        }
                    }
            ];

        return respite_crud.addToolbarActionButton(
            {
                extend: 'collection',
                text: (glyph == undefined || glyph == null ? '<i class="fas fa-download"></i> ' : '<i class="' + glyph + '"></i> ') + (title == undefined || title == null ? 'Export' : title),
                className: (customClass == undefined || customClass == null ? "btn btn-dark btn-sm" : customClass),
                buttons: arrButtons
            });
    }
    static addToggleColumnsButton(title, glyph, customClass) {
        return respite_crud.addToolbarActionButton(
            {
                extend: 'collection',
                text: (glyph == undefined || glyph == null ? '<i class="fas fa-eye"></i> ' : '<i class="' + glyph + '"></i> ') + (title == undefined || title == null ? 'Toggle Columns' : title),
                className: (customClass == undefined || customClass == null ? "btn btn-warning btn-sm" : customClass),
                buttons: [
                    { extend: 'columnsVisibility', columns: ['.dt-toggleable'] }
                ],
                visibility: true
            });
    }

        //// Add Columns ////
    static addColumn(objColumn) {
        if (respite_crud.dt != undefined) {
            throw "Error: New columns cannot be added after the datatable is already initialized!";
        }

        if (respite_crud.dt_Columns == undefined) {
            respite_crud.dt_Columns = []
        }

        respite_crud.dt_Columns.push(objColumn);

        return respite_crud;
    }

    static addRowReorderColumn(dataSrc) {
        if (respite_crud.respite_editor_options == undefined) {
            throw "Error: respite_editor_options must be initialized before adding row reorder column";
        }

        respite_crud.respite_editor_options.dt_Options.dt_RowReorder.row_reorder_column = dataSrc;

        // init defaults
        var setOptions = {
            target: null    // target element(s) to be updated with server response
            , beforeSubmit: respite_crud.respite_editor_options.dt_Options.dt_RowReorder.pre_submit_callback           // pre-submit callback
            , success: respite_crud.respite_editor_options.dt_Options.dt_RowReorder.response_success_callback          // post-submit callback
            , error: respite_crud.respite_editor_options.dt_Options.dt_RowReorder.response_error_callback              // post-submit callback

            // other available options:
            // ,url:       null                                     // override for form's 'action' attribute
            // ,type:      null                                     // 'get' or 'post', override for form's 'method' attribute
             , dataType: 'json'                                     // 'xml', 'script', or 'json' (expected server response type)
            // ,clearForm: true                                     // clear all form fields after successful submit
            // ,resetForm: true                                     // reset the form after successful submit

            // $.ajax options can be used here too, for example:
            // ,timeout:   3000
        }

        $(respite_crud.respite_editor_options.dt_Options.dt_RowReorder.form_selector).ajaxForm(setOptions);

        return respite_crud.addColumn({
            "class": "reorder",
            "orderable": true,
            "searchable": false,
            "data": dataSrc,
            "render": respite_crud.renderRowReorderCell
        });
    }

    static addInlineActionButtonsColumn() {
        return respite_crud.addColumn({
            "class": "actions-control",
            "orderable": false,
            "searchable": false,
            "data": null,
            "render": respite_crud.renderInlineActionButtons
        });
    }

        //// Set Columns Order ////
    static setColumnsOrder(options) {
        respite_crud.dt_Order = options;

        // return self to allow chaining
        return respite_crud;
    }

        //// Initialize DataTable ////
    static initDataTable(options) {
        // expose our "editor_data" extra column option using the api:
        $.fn.dataTable.Api.registerPlural('columns().editor_data()', 'column().editor_data()', function (setter) {
            return this.iterator('column', function (settings, column) {
                var col = settings.aoColumns[column];

                if (setter !== undefined) {
                    col.editor_data = setter;
                    return this;
                }
                else {
                    return col['editor_data'];
                }
            }, 1);
        });

        // expose "name" extra column option using the api:
        $.fn.dataTable.Api.registerPlural('columns().name()', 'column().name()', function (setter) {
            return this.iterator('column', function (settings, column) {
                var col = settings.aoColumns[column];

                if (setter !== undefined) {
                    col.name = setter;
                    return this;
                }
                else {
                    return col['name'];
                }
            }, 1);
        });

        // prepare default options
        respite_crud.setEditorOptions();

        // defaults
        if (respite_crud.dt_Order == undefined)
            respite_crud.dt_Order = [];

        if (respite_crud.dt_Buttons == undefined)
            respite_crud.dt_Buttons = [];

        var setOptions = {
            "processing": true,
            "serverSide": true,
            "deferRender": true,
            "scrollCollapse": true,
            "ajax": {
                url: respite_crud.respite_editor_options.dt_Options.dt_AjaxGet,
                type: 'POST'
            },
            "columns": respite_crud.dt_Columns,
            "order": respite_crud.dt_Order,

            //// Scroller Extension: //// remove or comment out this option to disable scroller and bring back pagination buttons
            //"scroller": {
            //    loadingIndicator: true
            //},

            //// Select Extension: //// remove or comment out this option to disable the select extension
            "select": 'os',

            //// Pagination: ////
            //"scrollX": 460,
            //"scrollY": 390,
            "lengthChange": true,           // allows users to change number of items visible in table (page size)
            "pagingType": "simple_numbers", // pagination type https://datatables.net/reference/option/pagingType
            "searchDelay": 700,

            //// DOM setting: //// more info here: https://datatables.net/reference/option/dom
            "dom": "<'dt-dynamic-filter-details'>Bilfpr<'table-responsive't>p", // TODO: the B section should only be added if toolbar buttons were added

            //// Custom Buttons: ////
            "buttons": {
                dom: {
                    container: { className: 'dt-buttons' }, // remove the default "btn-group" class
                    button: { className: '' } // remove the default "btn btn-default" class
                },
                buttons: respite_crud.dt_Buttons
            },
            "initComplete": function () {
                var urlFilter = false;

                // save footer
                var footerBefore = $(respite_crud.respite_editor_options.dt_Options.dt_Selector + ' tfoot tr').clone(true);

                // dropdown filters:
                this.api().columns('.dt-searchable-dropdown').every(function () {
                    var column = this;
                    var select = $('<select class="form-control"><option value="" style="font-weight: bold;">Search</option></select>')
                        .appendTo($(column.footer()).empty())
                        .on('change', function () {
                            var val = $.fn.dataTable.util.escapeRegex(
                                $(this).val()
                            );
                            //console.log('searching: ' + val);
                            column
                                .search(val != undefined && val != null ? val : '', true, false)
                                .draw();
                        });

                    if (respite_crud.dt_Columns[column[0]]['editor_data'] != undefined) {
                        // if boolean
                        switch (respite_crud.dt_Columns[column[0]].editor_data['type']) {
                            case "boolean":
                            case "boolean_switch":
                            case "boolean_checkbox":
                            case "boolean_radios":
                            case "boolean_button":
                                select.append('<option value="1"' + (column.search() == '1' ? ' selected="selected"' : '') + '>True</option>');
                                select.append('<option value="0"' + (column.search() == '0' ? ' selected="selected"' : '') + '>False</option>');
                                break;
                            default:
                                // otherwise, it's csv or select
                                // prepare list of available values by building a hash table
                                var existingValues = {}
                                column.data().unique().sort().each(function (d, j) {
                                    existingValues[d] = true;
                                });

                                var d = {}
                                var val = "";
                                for (var i = 0; respite_crud.dt_Columns[column[0]].editor_data['options'] != undefined && i < respite_crud.dt_Columns[column[0]].editor_data['options']['length']; i++) {
                                    d = respite_crud.dt_Columns[column[0]].editor_data['options'][i];
                                    val = $.fn.dataTable.util.escapeRegex(d.value);
                                    // if value exists in grid:
                                    if (existingValues[val]) {
                                        if (column.search() == val) {
                                            select.append(
                                              '<option value="' + val + '" selected="selected">' + d.label + "</option>"
                                            );
                                        } else {
                                            select.append('<option value="' + val + '">' + d.label + "</option>");
                                        }
                                    }
                                }
                                break;
                        }
                    }
                });

                // textual filters
                this.api().columns('.dt-searchable-text').every(function () {
                    var column = this;
                    var txt = $('<input type="search" class="form-control" placeholder="Search" />')
                        .appendTo($(column.footer()).empty())
                        .val(column.search().replace("%", "").replace("%", ""))
                        .on('change', function () {
                            var val = $.fn.dataTable.util.escapeRegex(
                                $(this).val()
                            );

                            column
                                .search(val ? '%' + val + '%' : '', true, false)
                                .draw();
                        });
                });
                // Copy footers to right below headers
                $(respite_crud.respite_editor_options.dt_Options.dt_Selector + ' tfoot tr').clone(true).appendTo(respite_crud.respite_editor_options.dt_Options.dt_Selector + ' thead');
                $(respite_crud.respite_editor_options.dt_Options.dt_Selector + ' thead tr:eq(1) th.dt-non-searchable').empty();

                // Reset footers
                $(respite_crud.respite_editor_options.dt_Options.dt_Selector + ' tfoot').empty();
                footerBefore.appendTo(respite_crud.respite_editor_options.dt_Options.dt_Selector + ' tfoot.dt-keep-footer');

                // refresh table:
                if (urlFilter) {
                    //console.log('url filtering on, refreshing table');
                    respite_crud.dt.ajax.reload();
                }
            }
        }

        // apply option overrides
        if (options != undefined) {
            for (var key in options) {
                setOptions[key] = options[key];
            }
        }

        // if not buttons were added, remove the B dom placeholder
        if (setOptions.buttons.length <= 0) {
            setOptions.dom = setOptions.dom.replace("B", "");
        }

        // if URL search parameters were specified, use them to apply column filters
        // issue #110: client state save overrides url parameters
        var searchCols = [];
        var colSearch = null;
        var currCol = "";

        for (var i = 0; i < setOptions.columns.length; i++) {
            colSearch = null;
            currCol = setOptions.columns[i]['name'];
            if (currCol != undefined) {
                colSearch = respite_crud.getUrlParam(currCol + '[search]');

                if (colSearch != undefined) {
                    colSearch = { "search": colSearch, "sSearch": colSearch, "escapeRegex": !(respite_crud.getUrlParam(currCol + '[regex]') == "true") }
                } else if (setOptions['searchCols'][i] != undefined) {
                    colSearch = setOptions.searchCols[i];
                } else {
                    colSearch = null;
                }
            }
            searchCols.push(colSearch);

            setOptions.searchCols = searchCols;
        }

        console.log("initializing datatable. options:");
        console.log(setOptions);

        $(document).ready(function () {
            //console.log(setOptions);
            //console.log(respite_crud.respite_editor_options.dt_Options.dt_Selector);
            respite_crud.dt = $(respite_crud.respite_editor_options.dt_Options.dt_Selector).DataTable(setOptions);

            respite_crud.dt.on('draw', function () {
                //dt-dynamic-filter-details
                $('body').find('.dt-dynamic-filter-details').empty();
                var urlParams = { ViewID: respite_crud.getUrlParam('ViewID') };
                var searchCols = respite_crud.dt.settings()[0].aoPreSearchCols; //setOptions.searchCols;
                var body = $('<div class="panel-body"></div>');
                var hasFilters = false;
                for (var i = 0; i < searchCols.length; i++) {
                    if (searchCols[i]['sSearch']) {
                        var col = setOptions.columns[i];
                        var searchVal = searchCols[i]['sSearch'];
                        var grp = $('<span role="group" style="margin-right: 5px"></span>');
                        var meta = {
                            "settings": { "aoColumns": respite_crud.dt.settings()[0].aoColumns },
                            "col": i
                        };

                        grp
                            .append(
                                    $('<span class="label label-primary"></span>')
                                    .append($('<a class="badge" data-toggle="tooltip" title="Remove filter" href="javascript:void(0)" onclick="respite_crud.clearColSearch(' + i + ')"><i class="fas fa-times"></i></a>'))
                                    .append($('<span></span>').text(' ' + (col['editor_data']['label'] || col['name']) + ':'))
                                    )
                            .append($('<span class="label label-default"></span>').text(
                            col.mRender(searchVal, undefined, undefined, meta)
                            || searchVal)
                            )
                        ;
                        body.append(grp.clone());
                        urlParams[col.name + '[search]'] = searchVal;
                        hasFilters = true;
                    }
                }
                if (hasFilters) {
                    var urlLink = window.location.pathname + '?' + $.param(urlParams);
                    $('body').find('.dt-dynamic-filter-details')
                        .append($('<div class="panel panel-info"></div>')
                            .append($('<div class="panel-heading"><span class="mr-auto"><i class="fas fa-filter"></i> Active Filters:</span></div>')
                                .append($('<a class="ml-auto float-right pull-right" data-toggle="tooltip" title="Get URL for this set of filters"><i class="fas fa-link"></i></a>').attr('href', urlLink))
                            )
                            .append(body)
                        );
                }


                // Implement URL-based editing
                if (!respite_crud.url_dml_opened && respite_crud.getUrlParam('mode') == 'edit' && respite_crud.getUrlParam('DT_ItemId') != undefined) {
                    var tr = $(respite_crud.respite_editor_options.dt_Options.dt_Selector).find('tr#' + respite_crud.getUrlParam('DT_ItemId'));
                    if (tr.length>0) {
                        tr.find('.' + respite_crud.edit_button_selector).trigger('click');
                        respite_crud.url_dml_opened = true;
                    } else {
                        console.log('Item ' + respite_crud.getUrlParam('DT_ItemId') + ' was not found in the datatable');
                    }
                } else if (!respite_crud.url_dml_opened && respite_crud.getUrlParam('mode') == 'delete' && respite_crud.getUrlParam('DT_ItemId') != undefined) {
                        var tr = $(respite_crud.respite_editor_options.dt_Options.dt_Selector).find('tr#' + respite_crud.getUrlParam('DT_ItemId'));
                        if (tr.length > 0) {
                            tr.find('.' + respite_crud.delete_button_selector).trigger('click');
                            respite_crud.url_dml_opened = true;
                        } else {
                            console.log('Item ' + respite_crud.getUrlParam('DT_ItemId') + ' was not found in the datatable');
                        }
                    }

                // If detail rows enabled
                if (respite_crud.isDetailRowsAdded) {
                    // On each draw, loop over the `detailRows` array and show any child rows
                    $.each(respite_crud.detailRows, function (i, id) {
                        $('#' + id + ' td a.details-control').trigger('click');
                    });
                }
            });

            // Implement row reordering event
            respite_crud.dt.on('row-reorder', function (e, diff, edit) {
                var changed = false;
                var inputList = $('<select name="DT_RowId" multiple="multiple"></select>');
                var options = respite_crud.respite_editor_options.dt_Options.dt_RowReorder;
                var frm = $(options.form_selector).hide();
                var frmBody = $(options.form_body_selector).empty();
                var rowData = {}
                var inputField = $('<input type="hidden" />');

                //console.log('Reorder started on row:');
                //console.log(edit.triggerRow.data());

                for (var i = 0, ien = diff.length ; i < ien ; i++) {
                    // if data indeed changed
                    if (diff[i].newData != diff[i].oldData) {
                        changed = true;

                        // get row data
                        rowData = respite_crud.dt.row(diff[i].node).data();

                        // generate hidden input
                        inputField = $('<input type="hidden" />');
                        inputField.attr('name', 'DT_RowId[' + rowData['DT_RowId'] + ']');
                        inputField.attr('value', diff[i].newData);

                        frmBody.append(inputField.clone());
                        inputList.append($('<option selected="selected">ID</option>').attr('value', rowData['DT_RowId']));

                        //console.log('updated: DT_RowId[' + rowData['DT_RowId'] + '] new value: ' + diff[i].newData + ' (was ' + diff[i].oldData + ')');
                    }
                }

                if (changed) {
                    frmBody.append(inputList);
                    //console.log(frmBody.html());
                    frm.submit();
                }
            });
        });
    }
    static clearColSearch(col) {
        respite_crud.dt.column(col).search('');
        respite_crud.dt.draw();
    }
}