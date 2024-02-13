<h1 align="center">🚨 ISA Staff PD Plugin</h1>

* Adds a 'PD Log' screen in the PowerSchool admin console to show a log of staff training (professional development)
* Writes to fields in a database extension table U_STAFF_TRAINING.U_TRAINING ENTRY
* Fields can also be updated through a form in the teacher portal


### [Historical Versions](https://github.com/InternationalSchoolAberdeen/ISAPowerSchoolPlugins/tree/main/ISA%20PD%20Log/Previous%20Versions)

## 🗃 Packaging The Plugin
> For each version update, update the `plugin.xml` and increment the `version` field <br>
> Select the `web_root` folder and the `plugin.xml` and add them both to a ZIP file <br>
> This ZIP file can then be uploaded to the `Plugin Management Screen` of PS

## Adding a field to the PD Log page

1. Create a database extension, eg `U_TRAINING_ENTRY.Location` with an appropriate data type
2. In `web_root/admin/faculty/pdlog.html` insert the field into the tlist SQL statement shown below, including the displaycols (field name) and field name (table column heading).
```html
~[tlist_child:Users.U_Staff_Training.U_Training_Entry;displaycols:Training_Date,Training_Name,Training_Provider;fieldNa
mes:Training Date, Name, Trainer Provider;type:html]
```   
3. You should now see the field added to the `PD Log Page` 

## Inserting the PD Log Page
* The `PD Log Page` is inserter into the admin menu for staff by using the `admin/faculty/more2.pdlog.leftnav.footer.txt` file.  The code is shown below - this should not need to be updated.

```javascript

<script>
	$j(document).ready(function()
		{
			$j('ul#tchr_information').append("<li><a href='pdlog.html?frn=~(frn)'>PD Log</a></li>");
		}
	);
</script>
```

## 📚 Changelog
- `v1.00`: Initial prototype installed
