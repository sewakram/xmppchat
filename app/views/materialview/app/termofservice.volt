<?php use Phalcon\Tag; ?>
  <!-- Modal Structure -->
  <div id="myModal" class="modal bottom-sheet">
    <div class="modal-content">
         <form action="#">
            <p>
                <input  value="true" type="checkbox" id="checkbox1" name="checkbox1" /> I agree to the sancharapp <a target="_blank" href="/terms">Terms of Service</a>
                <label for="checkbox1"> I agree to the sancharapp <a target="_blank" href="/terms">Terms of Service</a></label>
            </p>
             <p>
                <input value="true" id="checkbox2" name="checkbox2" type="checkbox" /> I agree to the sancharapp <a target="_blank" href="/terms">Terms of Service</a>
                <label for="checkbox2">Enjoy premium features for limited period.</label>
            </p>
    </form>
    </div>
    <div class="modal-footer">
      <a href="#!" class="modal-action modal-close waves-effect waves-green btn-flat ">Agree</a>
    </div>
  </div>