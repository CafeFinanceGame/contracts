// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./interfaces/ICAFItems.sol";
import {CAFModuleBase} from "../dependency/CAFModuleBase.sol";

abstract contract CAFItems is ICAFItems, CAFModuleBase {}
