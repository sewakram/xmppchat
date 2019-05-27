<?php use Phalcon\Tag; ?>
  <!-- Modal Structure -->
  <div id="image_modal" class="modal bottom-sheet">
    <div class="modal-content">
      <div><a href="#!" class="right modal-action modal-close waves-effect waves-red btn-flat">Close</a></div>
          <script type="text/javascript">
                      var finder = new CKFinder();
                      // The path for the installation of CKFinder (default = "/ckfinder/").
                      CKFinder.config.toolbar_Full = [['Upload','Refresh']];
                      finder.basePath = '../';
                      // finder.resourceType = 'Images';
                      // The default height is 400.
                      finder.height = 600;
                      // This is a sample function which is called when a file is selected in CKFinder.
                      finder.selectActionFunction = window.SetFileField;
                      finder.create();
          </script>
    </div>
  </div>